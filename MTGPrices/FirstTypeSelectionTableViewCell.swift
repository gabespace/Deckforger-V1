//
//  FirstTypeSelectionTableViewCell.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/3/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import UIKit
import DLRadioButton

class FirstTypeSelectionTableViewCell: UITableViewCell {
    
    var buttons = [DLRadioButton]()
    var rarities = ["Artifact", "Creature", "Enchantment"]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Create buttons.
        for rarity in rarities {
            buttons.append(createButton(title: rarity))
        }
        
        // Add buttons to subview.
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            addSubview(button)
        }
        
        // Create constraints for buttons.
        buttons.first!.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        buttons.last!.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        var previousButton: UIButton!
        for button in buttons {
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            button.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
            button.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0 / CGFloat(buttons.count)).isActive = true
            if previousButton != nil {
                button.leadingAnchor.constraint(equalTo: previousButton.trailingAnchor).isActive = true
            }
            previousButton = button
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createButton(title: String) -> DLRadioButton {
        let button = DLRadioButton()
        button.titleLabel!.font = UIFont.systemFont(ofSize: Constants.Button.fontSize)
        button.setTitle(title, for: .normal)
        button.setTitleColor(Constants.Button.textColor, for: .normal)
        button.iconColor = Constants.Button.color
        button.indicatorColor = Constants.Button.color
        button.isMultipleSelectionEnabled = true
        button.isIconSquare = true
        return button
    }
    
    struct Constants {
        static let borderMargin: CGFloat = 15
        
        struct Button {
            static let color = UIColor.darkGray
            static let textColor = UIColor.black
            static let fontSize: CGFloat = 14
            static let size: CGFloat = 24
            static let strokeWidth: CGFloat = 4
            static let indicatorSize: CGFloat = 12
            static let marginWidth: CGFloat = 12
        }
    }

}
