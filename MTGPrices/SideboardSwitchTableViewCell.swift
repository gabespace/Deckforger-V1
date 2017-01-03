//
//  SideboardSwitchTableViewCell.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/31/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import UIKit

class SideboardSwitchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var selectionSwitch: UISwitch!
    
    var switchDelegate: SwitchDelegate?
    
    @IBAction func selectedSwitch(_ sender: UISwitch) {
        switchDelegate?.switchDidToggle(to: sender.isOn, tag: sender.tag)
    }
    
}
