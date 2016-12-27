//
//  EditDeckTableViewController.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/26/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import UIKit
import ReSwift

class EditDeckTableViewController: UITableViewController, StoreSubscriber {
    
    var isCreatingNewDeck = false
    
    var deck: Deck?
    let formats = ["Casual", "Standard", "Frontier", "Modern", "Legacy", "Vintage", "EDH", "Pauper"]
    private var currentFormatIndex: Int!
    private var newName = "Untitled"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = isCreatingNewDeck ? "New Deck" : "Edit Deck"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEdits))
        
        currentFormatIndex = isCreatingNewDeck ? 0 : formats.index(of: deck!.format)!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveEdits() {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DeckNameTableViewCell
        if !cell.nameTextField.text!.isEmpty {
            newName = cell.nameTextField.text!
        }
        
        if isCreatingNewDeck {
            store.dispatch(AddNewDeck(name: newName, format: formats[currentFormatIndex]))
        } else {
            store.dispatch(EditDeck(deck: deck!, name: newName, format: formats[currentFormatIndex]))
        }
        
        _ = navigationController!.popViewController(animated: true)
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Name"
        } else {
            return "Format"
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return formats.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.deckName, for: indexPath) as! DeckNameTableViewCell
            cell.selectionStyle = .none
            cell.nameTextField.text = deck?.name ?? ""
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.deckFormat, for: indexPath)
            cell.textLabel?.text = formats[indexPath.row]
            if indexPath.row == currentFormatIndex {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.cellForRow(at: IndexPath(row: currentFormatIndex, section: 1))!.accessoryType = .none
        currentFormatIndex = indexPath.row
        tableView.cellForRow(at: indexPath)!.accessoryType = .checkmark
        
    }
    
    func newState(state: State) { }
    
    struct Cell {
        static let deckName = "Deck Name"
        static let deckFormat = "Deck Format"
    }

}
