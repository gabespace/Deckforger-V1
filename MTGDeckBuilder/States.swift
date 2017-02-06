//
//  States.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/28/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import ReSwift
import Alamofire

struct RootState: StateType {
    var coreDataState: CoreDataState
    var searchState: SearchState
}

struct CoreDataState: StateType {
    var decks: [Deck]!
    var coreDataError: CoreDataError?
    var isDownloadingImages: Bool
}

struct SearchState: StateType {
    var cardResults: Result<ApiResult>?
    var additionalCardResults: Result<ApiResult>?
    var parameters: [String: Any]?
    var shouldSearch: Bool
    var isLoading: Bool
    var currentRequestPage: Int
}
