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
    
    var decks = [Deck]()
    
    let request = Deck.createFetchRequest()
    let sort = NSSortDescriptor(key: "name", ascending: true)
    request.sortDescriptors = [sort]
    
    do {
        decks = try appDelegate.persistentContainer.viewContext.fetch(request)
    } catch {
        print("core data decks fetch failed")
    }
    
    return State(decks: decks, cardResults: nil, parameters: nil, shouldSearch: false, isLoading: false, additionalCardResults: nil, isDownloadingImages: false, currentRequestPage: 1)
}

struct StateReducer: Reducer {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func handleAction(action: Action, state: State?) -> State {
        var state = state ?? getInitialState()
        
        switch action {
            
        // MARK: - Deck Actions
            
        case let action as AddNewDeck:
            let deck = Deck(context: appDelegate.persistentContainer.viewContext)
            deck.name = action.name ?? "Untitled"
            deck.format = action.format
            deck.cards = []
            deck.id = UUID().uuidString
            deck.hasSideboard = action.hasSideboard
            appDelegate.saveContext()
            state.decks.append(deck)
            
        case let action as EditDeck:
            action.deck.name = action.name ?? action.deck.name
            if action.deck.format == "Commander" {
                // Delete commander cards.
                let request = Card.createFetchRequest()
                request.predicate = NSPredicate(format: "deck.id == %@ AND isCommander == true", action.deck.id)
                if let cards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                    for card in cards {
                        appDelegate.persistentContainer.viewContext.delete(card)
                    }
                }
            }
            action.deck.format = action.format ?? action.deck.format
            action.deck.hasSideboard = action.hasSideboard
            if !action.hasSideboard {
                // Delete all sideboard cards.
                let request = Card.createFetchRequest()
                request.predicate = NSPredicate(format: "deck.id == %@ AND isSideboard == true", action.deck.id)
                if let cards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                    for card in cards {
                        appDelegate.persistentContainer.viewContext.delete(card)
                    }
                }
            }
            appDelegate.saveContext()
            
        case let action as DeleteDeck:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@", action.deck.id)
            if let cards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                for card in cards {
                    appDelegate.persistentContainer.viewContext.delete(card)
                }
            } else {
                print("core data error- couldn't delete cards in the deck")
            }
            appDelegate.persistentContainer.viewContext.delete(action.deck)
            appDelegate.saveContext()

            
        // MARK: - Card Actions
            
        case let action as AddSideboardCardToDeck:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == false AND isCommander == false", action.deck.id, action.sideboardCard.id)
            if let existingCards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                if !existingCards.isEmpty {
                    // Card already exists in mainboard, just update its amount.
                    existingCards[0].amount += action.amount
                } else {
                    // Create new Card, add to deck.
                    let card = Card(context: appDelegate.persistentContainer.viewContext)
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
                print("core data error fetching")
            }
            appDelegate.saveContext()
        
        case let action as AddCardResultToDeck:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == false AND isCommander == false", action.deck.id, action.card.id)
            if let existingCards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                if !existingCards.isEmpty {
                    // Card exists, just update its amount.
                    let card = existingCards[0]
                    card.amount += action.amount
                } else {
                    // Create new card.
                    let card = Card(context: appDelegate.persistentContainer.viewContext)
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
                print("core data error fetching")
            }
            appDelegate.saveContext()
            
        case let action as AddMainboardCardToSideboard:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == true AND isCommander == false", action.deck.id, action.mainboardCard.id)
            if let existingCards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                if !existingCards.isEmpty {
                    // Card already exists in sideboard, just update its amount.
                    existingCards[0].amount += action.amount
                } else {
                    // Create new Card, add to deck.
                    let card = Card(context: appDelegate.persistentContainer.viewContext)
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
                print("core data error fetching")
            }
            appDelegate.saveContext()

        case let action as AddCardResultToSideboard:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == true AND isCommander == false", action.deck.id, action.card.id)
            if let existingCards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                if !existingCards.isEmpty {
                    // Card exists, just update its amount.
                    let card = existingCards[0]
                    card.amount += action.amount
                } else {
                    // Create new card.
                    let card = Card(context: appDelegate.persistentContainer.viewContext)
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
                print("core data error fetching")
            }
            appDelegate.saveContext()

        case let action as IncrementMainboardCardAmount:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == false AND isCommander == false", action.deck.id, action.card.id)
            if let cards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                if !cards.isEmpty {
                    cards[0].amount += action.amount
                }
            } else {
                print("core data error fetching")
            }
            appDelegate.saveContext()
            
        case let action as IncrementSideboardCardAmount:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == true AND isCommander == false", action.deck.id, action.card.id)
            if let cards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                if !cards.isEmpty {
                    cards[0].amount += action.amount
                }
            } else {
                print("core data error fetching")
            }
            appDelegate.saveContext()
            
        case let action as DecrementMainboardCardAmount:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == false AND isCommander == false", action.deck.id, action.cardId)
            if let cards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                if !cards.isEmpty {
                    cards[0].amount = max(cards[0].amount - action.amount, 0)
                }
            } else {
                print("core data error fetching")
            }
            appDelegate.saveContext()
            
        case let action as DecrementSideboardCardAmount:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == true AND isCommander == false", action.deck.id, action.cardId)
            if let cards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                if !cards.isEmpty {
                    cards[0].amount = max(cards[0].amount - action.amount, 0)
                }
            } else {
                print("core data error fetching")
            }
            appDelegate.saveContext()
            
        case let action as RemoveCardFromDeck:
            appDelegate.persistentContainer.viewContext.delete(action.card)
            appDelegate.saveContext()
            
        case let action as UpdateCardReference:
            let request = Card.createFetchRequest()
            request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@", action.deck.id, action.cardId)
            if let cards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                if !cards.isEmpty {
                    for card in cards {
                        if card.amount == 0 {
                            appDelegate.persistentContainer.viewContext.delete(card)
                        }
                    }
                }
            }
            appDelegate.saveContext()
            
        case let action as MakeCardCommander:
            if let cardResult = action.cardResult {
                // Add new commander card to deck from a CardResult.
                let request = Card.createFetchRequest()
                request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == false AND isCommander == true", action.deck.id, cardResult.id)
                if let existingCards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                    if existingCards.isEmpty {
                        let card = Card(context: appDelegate.persistentContainer.viewContext)
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
                    print("core data error fetching")
                }
            } else if let card = action.card {
                card.amount = 1
                card.isCommander = true
                appDelegate.saveContext()
            }
            
        case let action as UnmakeCardCommander:
            if let cardResult = action.cardResult {
                let request = Card.createFetchRequest()
                request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == false AND isCommander == true", action.deck.id, cardResult.id)
                if let existingCards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
                    if !existingCards.isEmpty {
                        existingCards[0].isCommander = false
                        appDelegate.saveContext()
                    }
                }
            } else if let card = action.card {
                card.isCommander = false
                appDelegate.saveContext()
            }
            
        // MARK: - Search Actions
            
        case let action as SearchForCards:
            state.cardResults = action.result
            state.parameters = action.parameters
            state.shouldSearch = false
            state.isLoading = action.isLoading
            state.currentRequestPage = action.currentPage
            
        case let action as SearchForAdditionalCards:
            state.additionalCardResults = action.result
            state.isLoading = action.isLoading
            
        case let action as PrepareForSearch:
            state.parameters = action.parameters
            state.shouldSearch = true
            
        case is ImagesDownloadComplete:
            state.isDownloadingImages = false
            
        default:
            break
            
        }
        
        return state
    }
    
}
