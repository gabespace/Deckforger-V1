//
//  Actions.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/28/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
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


// MARK: - Card Actions

struct AddSideboardCardToDeck: Action {
    let deck: Deck
    let sideboardCard: Card
    let amount: Int16
}

struct AddCardResultToDeck: Action {
    let deck: Deck
    let card: CardResult
    let amount: Int16
}

struct AddMainboardCardToSideboard: Action {
    let deck: Deck
    let mainboardCard: Card
    let amount: Int16
}

struct AddCardResultToSideboard: Action {
    let deck: Deck
    let card: CardResult
    let amount: Int16
}

struct IncrementMainboardCardAmount: Action {
    let deck: Deck
    let card: Card
    let amount: Int16
}

struct IncrementSideboardCardAmount: Action {
    let deck: Deck
    let card: Card
    let amount: Int16
}

struct DecrementMainboardCardAmount: Action {
    let deck: Deck
    let cardId: String
    let amount: Int16
}

struct DecrementSideboardCardAmount: Action {
    let deck: Deck
    let cardId: String
    let amount: Int16
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

// MARK: - Search Actions

struct PrepareForSearch: Action {
    let parameters: [String: Any]
}

struct SearchForCards: Action {
    let result: Result<ApiResult>?
    let parameters: [String: Any]
    let isLoading: Bool
}

struct SearchForAdditionalCards: Action {
    let result: Result<ApiResult>?
    let isLoading: Bool
}

struct ImagesDownloadComplete: Action { }
