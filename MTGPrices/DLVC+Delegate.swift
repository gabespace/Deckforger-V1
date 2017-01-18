//
//  DLVC+Delegate.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/28/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import UIKit

extension DeckListViewController: UITableViewDataSource, UITableViewDelegate, ButtonDelegate {
    
    // MARK: - Computed Properties
    
    var casualDecks: [Deck] {
        return decks.filter { $0.format == "Casual" }
    }
    
    var standardDecks: [Deck] {
        return decks.filter { $0.format == "Standard" }
    }
    
    var frontierDecks: [Deck] {
        return decks.filter { $0.format == "Frontier" }
    }
    
    var modernDecks: [Deck] {
        return decks.filter { $0.format == "Modern" }
    }
    
    var legacyDecks: [Deck] {
        return decks.filter { $0.format == "Legacy" }
    }
    
    var vintageDecks: [Deck] {
        return decks.filter { $0.format == "Vintage" }
    }
    
    var edhDecks: [Deck] {
        return decks.filter { $0.format == "Commander" }
    }
    
    var pauperDecks: [Deck] {
        return decks.filter { $0.format == "Pauper" }
    }
    
    var displayedDecks: [[Deck]] {
        var displayedDecks = [[Deck]]()
        if !casualDecks.isEmpty { displayedDecks.append(casualDecks) }
        if !standardDecks.isEmpty { displayedDecks.append(standardDecks) }
        if !frontierDecks.isEmpty { displayedDecks.append(frontierDecks) }
        if !modernDecks.isEmpty { displayedDecks.append(modernDecks) }
        if !legacyDecks.isEmpty { displayedDecks.append(legacyDecks) }
        if !vintageDecks.isEmpty { displayedDecks.append(vintageDecks) }
        if !edhDecks.isEmpty { displayedDecks.append(edhDecks) }
        if !pauperDecks.isEmpty { displayedDecks.append(pauperDecks) }
        return displayedDecks
    }
    
    
    // MARK: - TableView Data Source & Delegate Methods
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(displayedDecks[section][0].format) (\(displayedDecks[section].count))"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDecks[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return displayedDecks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.showDeckCellIdentifier, for: indexPath) as! DeckListTableViewCell
        let deck = displayedDecks[indexPath.section][indexPath.row]
        cell.buttonDelegate = self
        cell.nameLabel.text = deck.name
        cell.deckId = deck.id
        cell.editButton.setImage(UIImage(named: "edit.png"), for: .normal)
        let mainCount = deck.mainboardCount
        let sideCount = deck.sideboardCount
        var mainAttributes = [String: Any]()
        var sideAttributes = [String: Any]()
        if deck.format == "Commander" {
            mainAttributes[NSForegroundColorAttributeName] = mainCount < 100 ? UIColor.red : UIColor.black
        } else {
            mainAttributes[NSForegroundColorAttributeName] = mainCount < 60 ? UIColor.red : UIColor.black
        }
        sideAttributes[NSForegroundColorAttributeName] = sideCount < 15 ? UIColor.red : UIColor.black
        let attributedText = NSMutableAttributedString(string: "Main: \(mainCount)", attributes: mainAttributes)
        if deck.hasSideboard {
            attributedText.append(NSMutableAttributedString(string: " Side: \(sideCount)", attributes: sideAttributes))
        }
        cell.countLabel.attributedText = attributedText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "DeckViewController") as? DeckViewController {
            vc.deck = displayedDecks[indexPath.section][indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [unowned self] action in
                store.dispatch(DeleteDeck(deck: self.displayedDecks[indexPath.section][indexPath.row]))
            })
            present(ac, animated: true)
        }
    }
    
    
    // MARK: - ButtonDelegate Methods
    
    func buttonTapped(deckId id: String) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "EditDeckTableViewController") as? EditDeckTableViewController {
            vc.deck = decks[(decks.index { $0.id == id })!]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    // MARK: - Supporting Functionality
    
    struct Cell {
        static let addDeckCellIdentifier = "Add Deck"
        static let showDeckCellIdentifier = "Show Deck"
    }
    
}
