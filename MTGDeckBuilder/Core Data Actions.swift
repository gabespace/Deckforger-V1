//
//  Core Data Actions.swift
//  Deckforger
//
//  Created by Gabriele Pregadio on 2/15/17.
//  Copyright © 2017 Gabriele Pregadio. All rights reserved.
//

import Foundation
import ReSwift
import Alamofire


// MARK: - Deck Actions

struct AddNewDeck: Action {
    let name: String?
    let format: String!
    let hasSideboard: Bool
}

struct EditDeck: Action {
    let deck: Deck
    let name: String?
    let format: String?
    let hasSideboard: Bool
}

struct DeleteDeck: Action {
    let deck: Deck
}

struct DeleteEverything: Action { }


// MARK: - Card Actions

struct AddCardResultToDeck: Action {
    let deck: Deck
    let card: CardResult
    let amount: Int16
    let toSideboard: Bool
}

struct AddMainboardCardToSideboard: Action {
    let deck: Deck
    let mainboardCard: Card
    let amount: Int16
}

struct AddSideboardCardToMainboard: Action {
    let deck: Deck
    let sideboardCard: Card
    let amount: Int16
}

struct UpdateCardAmount: Action {
    let deck: Deck
    let cardId: String
    let amount: Int16
    let isSideboard: Bool
}

struct RemoveCardFromDeck: Action {
    let card: Card
}

struct UpdateCardReference: Action {
    let deck: Deck
    let cardId: String
}

struct MakeCardCommander: Action {
    let deck: Deck
    let card: Card?
    let cardResult: CardResult?
}

struct UnmakeCardCommander: Action {
    let deck: Deck
    let card: Card?
    let cardResult: CardResult?
}

struct ReDownloadImageForCard: Action {
    let card: Card
}
