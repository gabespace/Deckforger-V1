//
//  State.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/28/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import ReSwift
import Alamofire

struct State: StateType {
    var decks: [Deck]!
    var cardResults: Result<ApiResult>?
    var parameters: [String: Any]?
    var shouldSearch: Bool
    var isLoading: Bool
    var additionalCardResults: Result<ApiResult>?
    var isDownloadingImages: Bool
    var currentRequestPage: Int
    var error: CoreDataError?
}
