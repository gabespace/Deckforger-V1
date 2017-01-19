//
//  Search For Cards AC.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/29/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import ReSwift
import Alamofire
import ObjectMapper

func searchForCardsActionCreator(url: URLConvertible, parameters: Parameters, previousResults: [CardResult]?, currentPage: Int) -> Store<State>.ActionCreator {
    return { state, store in
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            // Completion handler.
            
            guard let json = response.result.value else {
                let errorCode = ErrorCode(rawValue: response.response?.statusCode ?? 0)
                let apiError = ApiError(status: errorCode, type: nil, message: "Unable to connect to online card database. Please check your network connection and try again.")
                store.dispatch(SearchForCards(result: Result.failure(apiError), parameters: parameters, isLoading: false, currentPage: currentPage))
                return
            }
            guard response.response?.statusCode == 200 else {
                let apiError = Mapper<ApiError>().map(JSONObject: json)!
                store.dispatch(SearchForCards(result: Result.failure(apiError), parameters: parameters, isLoading: false, currentPage: currentPage))
                return
            }
            
            if var apiResult = Mapper<ApiResult>().map(JSONObject: json) {
                if let previous = previousResults {
                    apiResult.cards.insert(contentsOf: previous, at: 0)
                }
                apiResult.headers = response.response?.allHeaderFields
                store.dispatch(SearchForCards(result: Result.success(apiResult), parameters: parameters, isLoading: false, currentPage: currentPage))
            }
        }
        return SearchForCards(result: nil, parameters: parameters, isLoading: true, currentPage: currentPage)
    }
}
