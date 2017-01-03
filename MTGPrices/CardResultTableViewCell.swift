//
//  CardResultTableViewCell.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/9/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import UIKit

class CardResultTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var costStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
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
