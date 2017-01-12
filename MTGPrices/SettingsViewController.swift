//
//  SettingsTableViewController.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 1/6/17.
//  Copyright © 2017 Gabriele Pregadio. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    let credits = [
        "Card data from magicthegathering.io",
        "Icons from icons8.com",
        "Mana Symbols by Goblin Hero"
    ]
    
    let links = [
        "https://magicthegathering.io/",
        "https://icons8.com/",
        "http://www.mtgsalvation.com/forums/creativity/artwork/494438-baconcatbugs-set-and-mana-symbol-megapack"
    ]
    
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Credits"
        
        for name in UIFont.familyNames {
            print(name)
            print(UIFont.fontNames(forFamilyName: name))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TableView Data Source
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Magic: the Gathering™ is TM and copyright Wizard of the Coast, Inc, a subsidiary of Hasbro, Inc. All rights reserved. This app is unaffiliated."
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.creditsCell, for: indexPath)
        cell.textLabel?.text = credits[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let url = URL(string: links[indexPath.row]) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    // MARK: - Supporting Functionality
    
    struct Cell {
        static let creditsCell = "Credits Cell"
    }
    
}
