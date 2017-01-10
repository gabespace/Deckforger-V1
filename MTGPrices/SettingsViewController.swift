//
//  SettingsTableViewController.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 1/6/17.
//  Copyright © 2017 Gabriele Pregadio. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, SwitchDelegate {
    
    // MARK: - Properties
    
    let defaults = UserDefaults.standard
    var isColorblindModeOn: Bool {
        return defaults.bool(forKey: "Colorblind Mode")
    }
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - SwitchDelegate Methods
    
    func switchDidToggle(to value: Bool, tag: Int) {
        defaults.set(value, forKey: "Colorblind Mode")
    }
    
    
    // MARK: - TableView Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.colorblindModeCell, for: indexPath) as! SideboardSwitchTableViewCell
        cell.switchDelegate = self
        cell.selectionSwitch.isOn = isColorblindModeOn
        return cell
    }
    
    
    // MARK: - Supporting Functionality
    
    struct Cell {
        static let colorblindModeCell = "Colorblind Mode Cell"
    }
    
}
