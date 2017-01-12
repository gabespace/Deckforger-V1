//
//  EditDeckTableViewController.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/26/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import UIKit
import ReSwift

class EditDeckTableViewController: UITableViewController, StoreSubscriber, UITextFieldDelegate, SwitchDelegate {
    
    // MARK: - Properties
    
    var isCreatingNewDeck = false
    
    var deck: Deck?
    private let formats = ["Casual", "Standard", "Frontier", "Modern", "Legacy", "Vintage", "Commander", "Pauper"]
    private var currentFormatIndex: Int!
    private var newName = "Untitled"
    private var hasSideboard: Bool!
    private var isNameBeingEdited = false
    
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = isCreatingNewDeck ? "New Deck" : "Edit Deck"
        
        newName = deck?.name ?? "Untitled"
        
        if isCreatingNewDeck {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(saveEdits))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveEdits))
        }
        
        currentFormatIndex = isCreatingNewDeck ? 0 : formats.index(of: deck!.format)!
        hasSideboard = deck?.hasSideboard ?? true
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
    
    
    // MARK: - Methods
    
    @objc private func saveEdits() {
        if isNameBeingEdited {
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DeckNameTableViewCell
            cell.nameTextField.resignFirstResponder()
        }
        
        if isCreatingNewDeck {
            store.dispatch(AddNewDeck(name: newName, format: formats[currentFormatIndex], hasSideboard: hasSideboard))
        } else {
            store.dispatch(EditDeck(deck: deck!, name: newName, format: formats[currentFormatIndex], hasSideboard: hasSideboard))
        }
        
        _ = navigationController!.popViewController(animated: true)
    }
    
    func deleteDeck() {
        store.dispatch(DeleteDeck(deck: deck!))
        _ = navigationController?.popViewController(animated: true)
    }
    
    func switchDidToggle(to value: Bool, tag: Int) {
        hasSideboard = value
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Name"
        case 1: return "Format"
        case 2: return "Sideboard"
        default: return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isCreatingNewDeck ? 3 : 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return formats.count
        case 2: return 1
        case 3: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.deckName, for: indexPath) as! DeckNameTableViewCell
            cell.nameTextField.delegate = self
            cell.selectionStyle = .none
            cell.nameTextField.text = newName
            cell.nameTextField.autocapitalizationType = .words
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.deckFormat, for: indexPath)
            cell.textLabel?.text = formats[indexPath.row]
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = indexPath.row == currentFormatIndex ? .checkmark : .none
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.deckSideboard, for: indexPath) as! SideboardSwitchTableViewCell
            cell.switchDelegate = self
            cell.selectionSwitch.isOn = hasSideboard
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.deckFormat, for: indexPath)
            cell.textLabel?.text = "Delete"
            cell.textLabel?.textColor = UIColor.red
            cell.accessoryType = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 1:
            tableView.cellForRow(at: IndexPath(row: currentFormatIndex, section: 1))!.accessoryType = .none
            currentFormatIndex = indexPath.row
            tableView.cellForRow(at: indexPath)!.accessoryType = .checkmark
        case 3:
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [unowned self] action in
                self.deleteDeck()
            })
            present(ac, animated: true)
        default: return
        }
    }
    
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isNameBeingEdited = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isNameBeingEdited = false
        newName = textField.text!.isEmpty ? "Untitled" : textField.text!
    }
    
    
    
    func newState(state: State) { }
    
    
    // MARK: - Supporting Functionality
    
    struct Cell {
        static let deckName = "Deck Name"
        static let deckFormat = "Deck Format"
        static let deckSideboard = "Deck Sideboard"
    }

}
