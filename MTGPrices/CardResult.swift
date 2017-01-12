//
//  CardResult.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/28/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import ObjectMapper

struct CardResult: Mappable {
    
    var name: String!
    var names: [String]?
    var manaCost: String?
    var cmc: String = "None"
    var rarity: String!
    var setName: String!
    var text: String?
    var power: String?
    var toughness: String?
    var imageUrl: String?
    var id: String!
    var colors: [String]? = ["Colorless"]
    var type: String!
    var subtypes: [String]?
    var types: [String]!
    var supertypes: [String]?
    var layout: String!
    var flavor: String?
    
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        
        let intToString = TransformOf<String, Int>(
            fromJSON: { (value: Int?) -> String? in
                if let value = value {
                    return String(value)
                } else {
                    return "None"
                }
            },
            toJSON:  { (value: String?) -> Int? in
                if let value = value {
                    return Int(value)
                } else {
                    return nil
                }
            }
        )
        
        name        <- map["name"]
        names       <- map["names"]
        manaCost    <- map["manaCost"]
        cmc         <- (map["cmc"], intToString)
        rarity      <- map["rarity"]
        setName     <- map["setName"]
        text        <- map["text"]
        power       <- map["power"]
        toughness   <- map["toughness"]
        imageUrl    <- map["imageUrl"]
        id          <- map["id"]
        colors      <- map["colors"]
        type        <- map["type"]
        subtypes    <- map["subtypes"]
        types       <- map["types"]
        supertypes  <- map["supertypes"]
        layout      <- map["layout"]
        flavor      <- map["flavor"]
        
    }
    
}
