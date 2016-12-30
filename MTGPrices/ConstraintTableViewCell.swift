//
//  ConstraintTableViewCell.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/29/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import UIKit

class ConstraintTableViewCell: UITableViewCell {

    @IBOutlet weak var selectionSwitch: UISwitch!
    @IBOutlet weak var label: UILabel!
    
    var switchDelegate: SwitchDelegate?
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        switchDelegate?.switchDidToggle(to: sender.isOn, tag: sender.tag)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

protocol SwitchDelegate {
    func switchDidToggle(to value: Bool, tag: Int)
}
