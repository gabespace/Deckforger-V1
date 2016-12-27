//
//  Deck+CoreDataClass.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/28/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import UIKit
import CoreData


public class Deck: NSManagedObject {
    var mainboardCount: Int {
        let request = Card.createFetchRequest()
        request.predicate = NSPredicate(format: "deck.id == %@ AND isSideboard == false", id)
        if let cards = try? (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.fetch(request) {
            return cards.reduce(0) { $0.0 + Int($0.1.amount) }
        } else {
            print("core data error fetching")
            return 0
        }
    }
    
    var sideboardCount: Int {
        let request = Card.createFetchRequest()
        request.predicate = NSPredicate(format: "deck.id == %@ AND isSideboard == true", id)
        if let cards = try? (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.fetch(request) {
            return cards.reduce(0) { $0.0 + Int($0.1.amount) }
        } else {
            print("core data error fetching")
            return 0
        }
    }
}
