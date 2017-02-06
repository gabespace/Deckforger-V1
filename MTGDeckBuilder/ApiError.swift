//
//  ApiError.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/29/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import ObjectMapper

struct ApiError: Mappable, Error {
    
    var status: ErrorCode?
    
    /// English description of `status`. Guaranteed to exist if `status` has a value.
    var type: String?

    var message: String?
    
    init?(map: Map) { }
    
    init(status: ErrorCode?, type: String?, message: String?) {
        self.status = status
        self.type = type
        self.message = message
    }
    
    mutating func mapping(map: Map) {
        status      <- map["status"]
        type        <- map["error"]
        message     <- map["message"]
    }
    
}
