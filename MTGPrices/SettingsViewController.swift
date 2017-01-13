//
//  SettingsTableViewController.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 1/6/17.
//  Copyright © 2017 Gabriele Pregadio. All rights reserved.
//

import UIKit
import ReSwift

class SettingsTableViewController: UITableViewController, StoreSubscriber {
    
    // MARK: - Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let credits = [
        "Card data from magicthegathering.io",
        "Icons from icons8.com",
        "Mana symbols by Goblin Hero"
    ]
    
    let links = [
        "https://magicthegathering.io/",
        "https://icons8.com/",
        "http://www.mtgsalvation.com/forums/creativity/artwork/494438-baconcatbugs-set-and-mana-symbol-megapack"
    ]
    
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    // MARK: - TableView Data Source
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 1 else { return nil }
        
        return "Magic: the Gathering™ is TM and copyright Wizard of the Coast, Inc, a subsidiary of Hasbro, Inc. All rights reserved. This app is unaffiliated."
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.settingsCell, for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.creditsCell, for: indexPath)
            cell.textLabel?.text = credits[indexPath.row]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        let ac = UIAlertController(title: "Delete All Data", message: "Are you sure? This action cannot be undone.", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            store.dispatch(DeleteEverything())
        })
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        
        if let url = URL(string: links[indexPath.row]) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    
    // MARK: - StoreSubscriber Delegate Methods
    
    func newState(state: State) { }
    
    
    // MARK: - Supporting Functionality
    
    struct Cell {
        static let settingsCell = "Settings Cell"
        static let creditsCell = "Credits Cell"
    }
    
}
