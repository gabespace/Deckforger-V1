//
//  CostFieldTableViewCell.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 1/10/17.
//  Copyright © 2017 Gabriele Pregadio. All rights reserved.
//

import UIKit

class CostFieldTableViewCell: UITableViewCell {
    
    @IBOutlet weak var costStackView: UIStackView!
    @IBOutlet weak var costLabel: UILabel!
    
    func configureCost(from imageViews: [UIImageView]?) {
        guard let imageViews = imageViews else {
            costStackView.isHidden = true
            return
        }
        
        costStackView.isHidden = false
        for view in costStackView.arrangedSubviews {
            costStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        for view in imageViews {
            costStackView.addArrangedSubview(view)
        }
    }
    
}
