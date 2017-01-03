//
//  Card+CoreDataProperties.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/31/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card");
    }

    @NSManaged public var amount: Int16
    @NSManaged public var cmc: String
    @NSManaged public var colors: String?
    @NSManaged public var id: String
    @NSManaged public var imageData: NSData?
    @NSManaged public var imageUrl: String?
    @NSManaged public var isDownloadingImage: Bool
    @NSManaged public var isSideboard: Bool
    @NSManaged public var layout: String
    @NSManaged public var manaCost: String?
    @NSManaged public var name: String
    @NSManaged public var names: String?
    @NSManaged public var power: String?
    @NSManaged public var rarity: String
    @NSManaged public var set: String
    @NSManaged public var text: String?
    @NSManaged public var toughness: String?
    @NSManaged public var type: String
    @NSManaged public var isCommander: Bool
    @NSManaged public var deck: Deck

}
