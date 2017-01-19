//
//  Deck+CoreDataProperties.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/31/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import CoreData


extension Deck {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Deck> {
        return NSFetchRequest<Deck>(entityName: "Deck");
    }

    @NSManaged public var folder: String?
    @NSManaged public var format: String
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var hasSideboard: Bool
    @NSManaged public var cards: NSSet

}

// MARK: Generated accessors for cards
extension Deck {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: Card)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: Card)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)

}
