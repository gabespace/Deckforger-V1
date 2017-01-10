//
//  String Extension.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/1/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var cmcToInt: Int {
        if self == "None" {
            return -1
        } else {
            return Int(self)!
        }
    }
    
    func createManaCostImages() -> [UIImageView] {
        var imageViews = [UIImageView]()
        var costStrings = self.components(separatedBy: "{")
        for (index, string) in costStrings.enumerated() {
            costStrings[index] = string.replacingOccurrences(of: "}", with: "")
            if let image = UIImage(named: costStrings[index].replacingOccurrences(of: "/", with: ":")) {
                imageViews.append(UIImageView(image: image))
            }
        }
        return imageViews
    }
    
    var withoutBraces: String {
        return self.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "")
    }
    
    func flippedNames() -> [String]? {
        let splitString = self.components(separatedBy: "|")
        return splitString.count > 1 ? splitString : nil
    }
}
