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

}

protocol SwitchDelegate {
    func switchDidToggle(to value: Bool, tag: Int)
}
