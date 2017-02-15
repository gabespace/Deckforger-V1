//
//  Search Actions.swift
//  Deckforger
//
//  Created by Gabriele Pregadio on 2/15/17.
//  Copyright © 2017 Gabriele Pregadio. All rights reserved.
//

import Foundation
import ReSwift
import Alamofire

struct ReceivedMemoryWarning: Action {
    let restorationIdentifier: String
}

struct PrepareForSearch: Action {
    let parameters: [String: Any]
}

struct SearchForCards: Action {
    let result: Result<ApiResult>?
    let parameters: [String: Any]
    let isLoading: Bool
    let currentPage: Int
}

struct SearchForAdditionalCards: Action {
    let result: Result<ApiResult>?
    let isLoading: Bool
}
