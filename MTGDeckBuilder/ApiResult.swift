//
//  ApiResult.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/29/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import ObjectMapper

struct ApiResult: Mappable {
    
    var cards: [CardResult]!
    var headers: [AnyHashable: Any]?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        cards   <- map["cards"]
    }
}
