//
//  CorneredImageView.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 1/10/17.
//  Copyright © 2017 Gabriele Pregadio. All rights reserved.
//

import UIKit

class CorneredImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
}
