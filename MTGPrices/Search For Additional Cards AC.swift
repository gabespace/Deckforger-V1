//
//  Search For Additional Cards AC.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/9/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import ReSwift
import Alamofire
import ObjectMapper

func searchForAdditionalCardsActionCreator(url: URLConvertible, parameters: Parameters) -> Store<State>.ActionCreator {
    return { state, store in
        
        Alamofire.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            // Completion handler
            
            guard let json = response.result.value else {
                print("error retrieving cards")
                let errorCode = ErrorCode(rawValue: response.response?.statusCode ?? 0)
                let apiError = ApiError(status: errorCode, type: nil, message: "Error retrieving card data")
                store.dispatch(SearchForAdditionalCards(result: Result.failure(apiError), isLoading: false))
                return
            }
            guard response.response?.statusCode == 200 else {
                print("error - status code isn't 200")
                // Assuming statusCode is guaranteed to have a non-optional value.
                // TODO: - Check that ^
                let apiError = Mapper<ApiError>().map(JSONObject: json)!
                store.dispatch(SearchForAdditionalCards(result: Result.failure(apiError), isLoading: false))
                return
            }
            
            if var apiResult = Mapper<ApiResult>().map(JSONObject: json) {
                apiResult.headers = response.response?.allHeaderFields
                store.dispatch(SearchForAdditionalCards(result: Result.success(apiResult), isLoading: false))
            }
        }
        return SearchForAdditionalCards(result: nil, isLoading: true)
    }
}
