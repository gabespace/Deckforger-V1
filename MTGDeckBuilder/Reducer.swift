//
//  Reducer.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/28/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import ReSwift
import CoreData

func getInitialState() -> State {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var coreDataError: CoreDataError?
    var decks = [Deck]()
    
    let request = Deck.createFetchRequest()
    let sort = NSSortDescriptor(key: "name", ascending: true)
    request.sortDescriptors = [sort]
    
    do {
        decks = try appDelegate.persistentContainer.viewContext.fetch(request)
    } catch {
        coreDataError = CoreDataError.loadingError("Unable to load stored decks. Please close the app and try again.")
    }
    
    return State(decks: decks, cardResults: nil, parameters: nil, shouldSearch: false, isLoading: false, additionalCardResults: nil, isDownloadingImages: false, currentRequestPage: 1, error: coreDataError)
}

struct StateReducer: Reducer {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func handleAction(action: Action, state: State?) -> State {
        var state = state ?? getInitialState()
        
        guard state.error == nil else { return state }
        
        let context = appDelegate.persistentContainer.viewContext
        
        switch action {
            
        // MARK: - Deck Actions
            
        case let action as AddNewDeck:
            let deck = Deck(context: context)
            deck.name = action.name ?? "Untitled"
            deck.format = action.format
            deck.cards = []
            deck.id = UUID().uuidString
            deck.hasSideboard = action.hasSideboard
            appDelegate.saveContext()
            state.decks.append(deck)
            state.error = nil
            
        case let action as EditDeck:
            action.deck.name = action.name ?? action.deck.name
            if action.deck.format == "Commander" {
                // Delete commander cards.
                let request = Card.createFetchRequest()
                request.predicate = NSPredicate(format: "deck.id == %@ AND isCommander == true", action.deck.id)
                if let cards = try? context.fetch(request) {
                    for card in cards {
                        context.delete(card)
                    }
                } else {
                    state.error = CoreDataError.loadingError("Unable to load this deck's commander and delete it. Please close the app and try again.")
                }
            }
            action.deck.format = action.format ?? action.deck.format
            action.deck.hasSideboard = action.hasSideboard
            if !action.hasSideboard {
                // Delete all sideboard cards.
                let request = Card.createFetchRequest()
                request.predicate = NSPredicate(format: "deck.id == %@ AND isSideboard == true", action.deck.id)
                if let cards = try? context.fetch(request) {
                    for card in cards {
                        context.delete(card)
                    }
                } else {
                    state.error = CoreDataError.loadingError("Unable to load and delete sideboard cards for this deck. Please close the app and try again.")
                }
            }
            appDelegate.saveContext()
            
        case let action as DeleteDeck:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@", action.deck.id)
            if let cards = try? context.fetch(request) {
                for card in cards {
                    context.delete(card)
                }
            } else {
                state.error = CoreDataError.loadingError("Unable to load this deck's cards and delete them. Please close the app and try again.")
            }
            context.delete(action.deck)
            appDelegate.saveContext()

        case is DeleteEverything:
            let cardRequest = Card.createFetchRequest()
            if let cards = try? context.fetch(cardRequest) {
                for card in cards {
                    context.delete(card)
                }
            }
            let deckRequest = Deck.createFetchRequest()
            if let decks = try? context.fetch(deckRequest) {
                for deck in decks {
                    context.delete(deck)
                }
            }
            appDelegate.saveContext()
            
        // MARK: - Card Actions
            
        case let action as AddSideboardCardToDeck:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == false AND isCommander == false", action.deck.id, action.sideboardCard.id)
            if let existingCards = try? context.fetch(request) {
                if !existingCards.isEmpty {
                    // Card already exists in mainboard, just update its amount.
                    existingCards[0].amount += action.amount
                } else {
                    // Create new Card, add to deck.
                    let card = Card(context: context)
                    card.imageData = action.sideboardCard.imageData
                    card.amount = action.amount
                    card.cmc = action.sideboardCard.cmc
                    card.colors = action.sideboardCard.colors
                    card.id = action.sideboardCard.id
                    card.imageUrl = action.sideboardCard.imageUrl
                    card.manaCost = action.sideboardCard.manaCost
                    card.name = action.sideboardCard.name
                    card.power = action.sideboardCard.power
                    card.rarity = action.sideboardCard.rarity
                    card.setName = action.sideboardCard.setName
                    card.text = action.sideboardCard.text
                    card.flavor = action.sideboardCard.flavor
                    card.toughness = action.sideboardCard.toughness
                    card.type = action.sideboardCard.type
                    card.names = action.sideboardCard.names
                    card.layout = action.sideboardCard.layout
                    card.isDownloadingImage = false
                    card.isSideboard = false
                    card.isCommander = false
                    card.deck = action.deck
                }
            } else {
                state.error = CoreDataError.loadingError("Unable to load this deck's sideboard. Please close the app and try again.")
            }
            appDelegate.saveContext()
        
        case let action as AddCardResultToDeck:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == false AND isCommander == false", action.deck.id, action.card.id)
            if let existingCards = try? context.fetch(request) {
                if !existingCards.isEmpty {
                    // Card exists, just update its amount.
                    let card = existingCards[0]
                    card.amount += action.amount
                } else {
                    // Create new card.
                    let card = Card(context: context)
                    if let imageUrl = action.card.imageUrl {
                        // Download image.
                        card.isDownloadingImage = true
                        state.isDownloadingImages = true
                        let url = URL(string: imageUrl)!
                        DispatchQueue.global(qos: .userInteractive).async {
                            if let data = try? Data(contentsOf: url) {
                                DispatchQueue.main.async {
                                    card.imageData = data as NSData
                                    card.isDownloadingImage = false
                                    store.dispatch(ImagesDownloadComplete())
                                }
                            } else {
                                DispatchQueue.main.async {
                                    card.isDownloadingImage = false
                                    store.dispatch(ImagesDownloadComplete())
                                }
                            }
                        }
                    } else {
                        card.isDownloadingImage = false
                    }
                    card.cmc = action.card.cmc
                    card.id = action.card.id
                    card.imageUrl = action.card.imageUrl
                    card.manaCost = action.card.manaCost
                    card.name = action.card.name
                    card.power = action.card.power
                    card.rarity = action.card.rarity
                    card.setName = action.card.setName
                    card.toughness = action.card.toughness
                    card.type = action.card.type
                    card.text = action.card.text
                    card.flavor = action.card.flavor
                    card.colors = action.card.colors?.joined(separator: ", ") ?? "Colorless"
                    card.names = action.card.names?.joined(separator: "|")
                    card.layout = action.card.layout
                    card.amount = action.amount
                    card.isSideboard = false
                    card.isCommander = false
                    card.deck = action.deck
                }
            } else {
                state.error = CoreDataError.loadingError("Unable to load this deck's mainboard. Please close the app and try again.")
            }
            appDelegate.saveContext()
            
        case let action as AddMainboardCardToSideboard:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == true AND isCommander == false", action.deck.id, action.mainboardCard.id)
            if let existingCards = try? context.fetch(request) {
                if !existingCards.isEmpty {
                    // Card already exists in sideboard, just update its amount.
                    existingCards[0].amount += action.amount
                } else {
                    // Create new Card, add to deck.
                    let card = Card(context: context)
                    card.imageData = action.mainboardCard.imageData
                    card.amount = action.amount
                    card.cmc = action.mainboardCard.cmc
                    card.colors = action.mainboardCard.colors
                    card.id = action.mainboardCard.id
                    card.imageUrl = action.mainboardCard.imageUrl
                    card.manaCost = action.mainboardCard.manaCost
                    card.name = action.mainboardCard.name
                    card.power = action.mainboardCard.power
                    card.rarity = action.mainboardCard.rarity
                    card.setName = action.mainboardCard.setName
                    card.text = action.mainboardCard.text
                    card.flavor = action.mainboardCard.flavor
                    card.toughness = action.mainboardCard.toughness
                    card.type = action.mainboardCard.type
                    card.names = action.mainboardCard.names
                    card.layout = action.mainboardCard.layout
                    card.isDownloadingImage = false
                    card.isSideboard = true
                    card.isCommander = false
                    card.deck = action.deck
                }
            } else {
                state.error = CoreDataError.loadingError("Unable to load this deck's sideboard. Please close the app and try again.")
            }
            appDelegate.saveContext()

        case let action as AddCardResultToSideboard:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == true AND isCommander == false", action.deck.id, action.card.id)
            if let existingCards = try? context.fetch(request) {
                if !existingCards.isEmpty {
                    // Card exists, just update its amount.
                    let card = existingCards[0]
                    card.amount += action.amount
                } else {
                    // Create new card.
                    let card = Card(context: context)
                    if let imageUrl = action.card.imageUrl {
                        // Download image.
                        card.isDownloadingImage = true
                        state.isDownloadingImages = true
                        let url = URL(string: imageUrl)!
                        DispatchQueue.global(qos: .userInteractive).async {
                            if let data = try? Data(contentsOf: url) {
                                DispatchQueue.main.async {
                                    card.imageData = data as NSData
                                    card.isDownloadingImage = false
                                    store.dispatch(ImagesDownloadComplete())
                                }
                            } else {
                                DispatchQueue.main.async {
                                    card.isDownloadingImage = false
                                    store.dispatch(ImagesDownloadComplete())
                                }
                            }
                        }
                    } else {
                        card.isDownloadingImage = false
                    }
                    card.cmc = action.card.cmc
                    card.id = action.card.id
                    card.imageUrl = action.card.imageUrl
                    card.manaCost = action.card.manaCost
                    card.name = action.card.name
                    card.power = action.card.power
                    card.rarity = action.card.rarity
                    card.setName = action.card.setName
                    card.toughness = action.card.toughness
                    card.type = action.card.type
                    card.text = action.card.text
                    card.flavor = action.card.flavor
                    card.colors = action.card.colors?.joined(separator: ", ") ?? "Colorless"
                    card.names = action.card.names?.joined(separator: "|")
                    card.layout = action.card.layout
                    card.amount = action.amount
                    card.isSideboard = true
                    card.isCommander = false
                    card.deck = action.deck
                }
            } else {
                state.error = CoreDataError.loadingError("Unable to load this deck's sideboard. Please close the app and try again.")
            }
            appDelegate.saveContext()

        case let action as IncrementMainboardCardAmount:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == false AND isCommander == false", action.deck.id, action.card.id)
            if let cards = try? context.fetch(request) {
                if !cards.isEmpty {
                    cards[0].amount += action.amount
                }
            } else {
                state.error = CoreDataError.loadingError("Unable to load this deck's mainboard. Please close the app and try again.")
            }
            appDelegate.saveContext()
            
        case let action as IncrementSideboardCardAmount:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == true AND isCommander == false", action.deck.id, action.card.id)
            if let cards = try? context.fetch(request) {
                if !cards.isEmpty {
                    cards[0].amount += action.amount
                }
            } else {
                state.error = CoreDataError.loadingError("Unable to load this deck's sideboard. Please close the app and try again.")
            }
            appDelegate.saveContext()
            
        case let action as DecrementMainboardCardAmount:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == false AND isCommander == false", action.deck.id, action.cardId)
            if let cards = try? context.fetch(request) {
                if !cards.isEmpty {
                    cards[0].amount = max(cards[0].amount - action.amount, 0)
                }
            } else {
                state.error = CoreDataError.loadingError("Unable to load this deck's mainboard. Please close the app and try again.")
            }
            appDelegate.saveContext()
            
        case let action as DecrementSideboardCardAmount:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == true AND isCommander == false", action.deck.id, action.cardId)
            if let cards = try? context.fetch(request) {
                if !cards.isEmpty {
                    cards[0].amount = max(cards[0].amount - action.amount, 0)
                }
            } else {
                state.error = CoreDataError.loadingError("Unable to load this deck's sideboard. Please close the app and try again.")
            }
            appDelegate.saveContext()
            
        case let action as RemoveCardFromDeck:
            context.delete(action.card)
            appDelegate.saveContext()
            state.error = nil
            
        case let action as UpdateCardReference:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@", action.deck.id, action.cardId)
            if let cards = try? context.fetch(request) {
                if !cards.isEmpty {
                    for card in cards {
                        if card.amount == 0 {
                            context.delete(card)
                        }
                    }
                }
            } else {
                state.error = CoreDataError.loadingError("Unable to load this deck's cards. Please close the app and try again.")
            }
            appDelegate.saveContext()
            
        case let action as MakeCardCommander:
            if let cardResult = action.cardResult {
                // Add new commander card to deck from a CardResult.
                let request = Card.createFetchRequest()
                request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isCommander == true", action.deck.id, cardResult.id)
                if let existingCards = try? context.fetch(request) {
                    if existingCards.isEmpty {
                        let card = Card(context: context)
                        if let imageUrl = cardResult.imageUrl {
                            // Download image.
                            card.isDownloadingImage = true
                            state.isDownloadingImages = true
                            let url = URL(string: imageUrl)!
                            DispatchQueue.global(qos: .userInteractive).async {
                                if let data = try? Data(contentsOf: url) {
                                    DispatchQueue.main.async {
                                        card.imageData = data as NSData
                                        card.isDownloadingImage = false
                                        store.dispatch(ImagesDownloadComplete())
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        card.isDownloadingImage = false
                                        store.dispatch(ImagesDownloadComplete())
                                    }
                                }
                            }
                        } else {
                            card.isDownloadingImage = false
                        }
                        card.amount = 1
                        card.cmc = cardResult.cmc
                        card.id = cardResult.id
                        card.imageUrl = cardResult.imageUrl
                        card.manaCost = cardResult.manaCost
                        card.name = cardResult.name
                        card.power = cardResult.power
                        card.rarity = cardResult.rarity
                        card.setName = cardResult.setName
                        card.toughness = cardResult.toughness
                        card.type = cardResult.type
                        card.text = cardResult.text
                        card.flavor = cardResult.flavor
                        card.colors = cardResult.colors?.joined(separator: ", ") ?? "Colorless"
                        card.names = cardResult.names?.joined(separator: "|")
                        card.layout = cardResult.layout
                        card.isSideboard = false
                        card.isCommander = true
                        card.deck = action.deck
                        appDelegate.saveContext()
                    }
                } else {
                    state.error = CoreDataError.loadingError("Unable to load this deck's cards. Please close the app and try again.")
                }
            } else if let card = action.card {
                card.amount = 1
                card.isCommander = true
                appDelegate.saveContext()
                state.error = nil
            }
            
        case let action as UnmakeCardCommander:
            if let cardResult = action.cardResult {
                let request = Card.createFetchRequest()
                request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isCommander == true", action.deck.id, cardResult.id)
                if let existingCards = try? context.fetch(request) {
                    if !existingCards.isEmpty {
                        existingCards[0].isCommander = false
                        appDelegate.saveContext()
                    }
                } else {
                    state.error = CoreDataError.loadingError("Unable to load this deck's cards. Please close the app and try again.")
                }
            } else if let card = action.card {
                card.isCommander = false
                appDelegate.saveContext()
            }
            
        case let action as ReDownloadImageForCard:
            guard let urlString = action.card.imageUrl else { break }
            
            action.card.isDownloadingImage = true
            state.isDownloadingImages = true
            if let url = URL(string: urlString) {
                DispatchQueue.global(qos: .userInteractive).async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            action.card.imageData = data as NSData
                            action.card.isDownloadingImage = false
                            store.dispatch(ImagesDownloadComplete())
                        }
                    } else {
                        DispatchQueue.main.async {
                            action.card.isDownloadingImage = false
                            store.dispatch(ImagesDownloadComplete())
                        }
                    }
                }
            }
            
        // MARK: - Search Actions
            
        case let action as SearchForCards:
            state.cardResults = action.result
            state.parameters = action.parameters
            state.shouldSearch = false
            state.isLoading = action.isLoading
            state.currentRequestPage = action.currentPage
            state.error = nil
            
        case let action as SearchForAdditionalCards:
            state.additionalCardResults = action.result
            state.isLoading = action.isLoading
            state.error = nil
            
        case let action as PrepareForSearch:
            state.parameters = action.parameters
            state.shouldSearch = true
            state.error = nil
            
        case is ImagesDownloadComplete:
            state.isDownloadingImages = false
            state.error = nil
            
        default:
            break
            
        }
        
        return state
    }
    
}
