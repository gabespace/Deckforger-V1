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
}

struct EditDeck: Action {
    let deck: Deck
    let name: String?
    let format: String?
}

struct DeleteDeck: Action {
    let deck: Deck
}


// MARK: - Card Actions

struct AddSideboardCardToDeck: Action {
    let deck: Deck
    let sideboardCard: Card
}

struct AddCardResultToDeck: Action {
    let deck: Deck
    let card: CardResult
}

struct AddMainboardCardToSideboard: Action {
    let deck: Deck
    let mainboardCard: Card
}

struct AddCardResultToSideboard: Action {
    let deck: Deck
    let card: CardResult
}

struct IncrementMainboardCardAmount: Action {
    let deck: Deck
    let card: Card
}

struct IncrementSideboardCardAmount: Action {
    let deck: Deck
    let card: Card
}

struct DecrementMainboardCardAmount: Action {
    let deck: Deck
    let cardId: String
}

struct DecrementSideboardCardAmount: Action {
    let deck: Deck
    let cardId: String
}

struct RemoveCardFromDeck: Action {
    let card: Card
}

struct UpdateCardReference: Action {
    let deck: Deck
    let cardId: String
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
