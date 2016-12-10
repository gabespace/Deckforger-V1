//
//  DeckViewController Extension.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/30/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//
import Foundation
import UIKit

extension DeckViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Computed Properties
    
    var creaturesCount: Int {
        var count = 0
        for creature in creatures {
            count += Int(creature.amount)
        }
        return count
    }
    
    var spellsCount: Int {
        var count = 0
        for spell in spells {
            count += Int(spell.amount)
        }
        return count
    }
    
    var landsCount: Int {
        var count = 0
        for land in lands {
            count += Int(land.amount)
        }
        return count
    }
    
    
    // MARK: - UITableViewDelegate, UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "\(creaturesCount) Creatures"
        case 1: return "\(spellsCount) Noncreature Spells"
        case 2: return "\(landsCount) Lands"
        default: return nil
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // Creature
            return creatures.count
        case 1:
            // Spell
            return spells.count
        default:
            // Land
            return lands.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            // Creature
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.creatureCell, for: indexPath) as! CardTableViewCell
            let creature = creatures[indexPath.row]
            cell.amountLabel.text = "\(creature.amount)"
            cell.title.text = creature.name
            cell.subtitle.text = creature.type
            if !creature.isDownloadingImage && creature.imageUrl != nil {
                cell.cardImageView.isHidden = false
                cell.imageLabel.isHidden = true
                cell.cardImageView.image = UIImage(data: creature.imageData! as Data)
                cell.configureFrame()
            } else if creature.isDownloadingImage {
                cell.imageLabel.isHidden = false
                cell.imageLabel.text = "Loading Image"
                cell.cardImageView.isHidden = true
            } else {
                cell.imageLabel.isHidden = false
                cell.imageLabel.text = "No Image"
                cell.cardImageView.isHidden = true
            }
            cell.configureCost(from: creature.manaCost!.createManaCostImages())
            return cell
        case 1:
            // Spell
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.spellCell, for: indexPath)  as! CardTableViewCell
            let spell = spells[indexPath.row]
            cell.amountLabel.text = "\(spell.amount)"
            cell.title.text = spell.name
            cell.subtitle.text = spell.type
            if !spell.isDownloadingImage && spell.imageUrl != nil {
                cell.cardImageView.isHidden = false
                cell.imageLabel.isHidden = true
                cell.cardImageView.image = UIImage(data: spell.imageData! as Data)
                cell.configureFrame()
            } else if spell.isDownloadingImage {
                cell.imageLabel.isHidden = false
                cell.imageLabel.text = "Loading Image"
                cell.cardImageView.isHidden = true
            } else {
                cell.imageLabel.isHidden = false
                cell.imageLabel.text = "No Image"
                cell.cardImageView.isHidden = true
            }
            cell.configureCost(from: spell.manaCost?.createManaCostImages())
            return cell
        default:
            // Land
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.landCell, for: indexPath) as! CardTableViewCell
            let land = lands[indexPath.row]
            cell.amountLabel.text = "\(land.amount)"
            cell.title.text = land.name
            cell.subtitle.text = land.type
            if !land.isDownloadingImage && land.imageUrl != nil {
                cell.cardImageView.isHidden = false
                cell.imageLabel.isHidden = true
                cell.cardImageView.image = UIImage(data: land.imageData! as Data)
                cell.configureFrame()
            } else if land.isDownloadingImage {
                cell.imageLabel.isHidden = false
                cell.imageLabel.text = "Loading Image"
                cell.cardImageView.isHidden = true
            } else {
                cell.imageLabel.isHidden = false
                cell.imageLabel.text = "No Image"
                cell.cardImageView.isHidden = true
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "CardDetailViewController") as? CardDetailViewController {
            vc.deck = deck
            switch indexPath.section {
            case 0: vc.card = creatures[indexPath.row]
            case 1: vc.card = spells[indexPath.row]
            default: vc.card = lands[indexPath.row]
            }
            vc.shouldUseResult = false
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let card = getCardAtIndexPath(indexPath)
            cards.remove(at: cards.index(of: card)!)
            store.dispatch(RemoveCardFromDeck(card: card))
        }
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let card = getCardAtIndexPath(indexPath)
        store.dispatch(IncrementCardAmount(card: card))
    }
    
    // MARK: - Supporting Functionality
    
    struct Cell {
        static let creatureCell = "Creature"
        static let spellCell = "Spell"
        static let landCell = "Land"
    }
    
    func getCardAtIndexPath(_ indexPath: IndexPath) -> Card {
        switch indexPath.section {
        case 0: return creatures[indexPath.row]
        case 1: return spells[indexPath.row]
        default: return lands[indexPath.row]
        }
    }
    
}
