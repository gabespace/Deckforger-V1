//
//  DVC+TableViewData.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/30/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//
import Foundation
import UIKit

extension DeckViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Computed Properties
    
    var commanders: [Card] {
        return cards.filter { $0.isCommander }.sorted {
            if $0.0.cmc.cmcToInt != $0.1.cmc.cmcToInt {
                return $0.0.cmc.cmcToInt < $0.1.cmc.cmcToInt
            } else {
                return $0.0.name < $0.1.name
            }
        }
    }
    
    var creatures: [Card] {
        return cards.filter { !$0.isCommander && !$0.isSideboard && ($0.type.contains("Creature") || $0.type.contains("Summon")) && !$0.type.contains("Land") }.sorted {
            if $0.0.cmc.cmcToInt != $0.1.cmc.cmcToInt {
                return $0.0.cmc.cmcToInt < $0.1.cmc.cmcToInt
            } else {
                return $0.0.name < $0.1.name
            }
        }
    }
    
    var spells: [Card] {
        return cards.filter { !$0.isCommander && !$0.isSideboard && !$0.type.contains("Creature") && !$0.type.contains("Land") }.sorted {
            if $0.0.cmc.cmcToInt != $0.1.cmc.cmcToInt {
                return $0.0.cmc.cmcToInt < $0.1.cmc.cmcToInt
            } else {
                return $0.0.name < $0.1.name
            }
        }
    }
    
    var lands: [Card] {
        return cards.filter { !$0.isSideboard && $0.type.contains("Land") }.sorted { $0.0.name < $0.1.name }
    }
    
    var sideboard: [Card] {
        return cards.filter { $0.isSideboard }.sorted {
            if $0.0.cmc.cmcToInt != $0.1.cmc.cmcToInt {
                return $0.0.cmc.cmcToInt < $0.1.cmc.cmcToInt
            } else {
                return $0.0.name < $0.1.name
            }
        }
    }
    
    var creaturesCount: Int {
        return creatures.reduce(0) { $0 + Int($1.amount) }
    }
    
    var spellsCount: Int {
        return spells.reduce(0) { $0 + Int($1.amount) }
    }
    
    var landsCount: Int {
        return lands.reduce(0) { $0 + Int($1.amount) }
    }
    
    var sideboardCount: Int {
        return sideboard.reduce(0) { $0 + Int($1.amount) }
    }
    
    
    // MARK: - UITableViewDelegate, UITableViewDataSource Methods
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = isCommander ? section - 1 : section
        switch section {
        case -1: return commanders.count > 1 ? "Commanders" : "Commander"
        case 0: return "Creatures (\(creaturesCount))"
        case 1: return "Noncreature Spells (\(spellsCount))"
        case 2: return "Lands (\(landsCount))"
        case 3: return "Sideboard (\(sideboardCount))"
        default: return nil
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch (isCommander, deck.hasSideboard) {
        case (true, true): return 5
        case (true, false): return 4
        case (false, true): return 4
        case (false, false): return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = isCommander ? section - 1 : section
        switch section {
        case -1: return commanders.count
        case 0: return creatures.count
        case 1: return spells.count
        case 2: return lands.count
        case 3: return sideboard.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = isCommander ? indexPath.section - 1 : indexPath.section
        switch section {
        case -1:
            // Commander
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.creatureCell, for: indexPath) as! CardTableViewCell
            let creature = commanders[indexPath.row]
            cell.amountLabel.text = "\(creature.amount)"
            cell.title.text = creature.name
            cell.subtitle.text = creature.type
            if !creature.isDownloadingImage && creature.imageData != nil {
                cell.imageLabel.isHidden = true
                cell.cardImageView.isHidden = false
                cell.cardImageView.image = UIImage(data: creature.imageData! as Data)
            } else {
                cell.imageLabel.isHidden = false
                cell.imageLabel.text = creature.isDownloadingImage ? "Loading Image" : "No Image"
                cell.cardImageView.isHidden = true
            }
            cell.configureCost(from: creature.manaCost?.createManaCostImages())
            return cell
        case 0:
            // Creature
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.creatureCell, for: indexPath) as! CardTableViewCell
            let creature = creatures[indexPath.row]
            cell.amountLabel.text = "\(creature.amount)"
            cell.title.text = creature.name
            cell.subtitle.text = creature.type
            if !creature.isDownloadingImage && creature.imageData != nil {
                cell.imageLabel.isHidden = true
                cell.cardImageView.isHidden = false
                cell.cardImageView.image = UIImage(data: creature.imageData! as Data)
            } else {
                cell.imageLabel.isHidden = false
                cell.imageLabel.text = creature.isDownloadingImage ? "Loading Image" : "No Image"
                cell.cardImageView.isHidden = true
            }
            cell.configureCost(from: creature.manaCost?.createManaCostImages())
            return cell
        case 1:
            // Spell
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.spellCell, for: indexPath)  as! CardTableViewCell
            let spell = spells[indexPath.row]
            cell.amountLabel.text = "\(spell.amount)"
            cell.title.text = spell.name
            cell.subtitle.text = spell.type
            if !spell.isDownloadingImage && spell.imageData != nil {
                cell.imageLabel.isHidden = true
                cell.cardImageView.isHidden = false
                cell.cardImageView.image = UIImage(data: spell.imageData! as Data)
            } else {
                cell.imageLabel.isHidden = false
                cell.imageLabel.text = spell.isDownloadingImage ? "Loading Image" : "No Image"
                cell.cardImageView.isHidden = true
            }
            cell.configureCost(from: spell.manaCost?.createManaCostImages())
            return cell
        case 2:
            // Land
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.landCell, for: indexPath) as! CardTableViewCell
            let land = lands[indexPath.row]
            cell.amountLabel.text = "\(land.amount)"
            cell.title.text = land.name
            cell.subtitle.text = land.type
            if !land.isDownloadingImage && land.imageData != nil {
                cell.imageLabel.isHidden = true
                cell.cardImageView.isHidden = false
                cell.cardImageView.image = UIImage(data: land.imageData! as Data)
            } else {
                cell.imageLabel.isHidden = false
                cell.imageLabel.text = land.isDownloadingImage ? "Loading Image" : "No Image"
                cell.cardImageView.isHidden = true
            }
            return cell
        default:
            // Sideboard
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.sideboardCell, for: indexPath) as! CardTableViewCell
            let sideboardCard = sideboard[indexPath.row]
            cell.amountLabel.text = "\(sideboardCard.amount)"
            cell.title.text = sideboardCard.name
            cell.subtitle.text = sideboardCard.type
            if !sideboardCard.isDownloadingImage && sideboardCard.imageData != nil {
                cell.imageLabel.isHidden = true
                cell.cardImageView.isHidden = false
                cell.cardImageView.image = UIImage(data: sideboardCard.imageData! as Data)
            } else {
                cell.imageLabel.isHidden = false
                cell.imageLabel.text = sideboardCard.isDownloadingImage ? "Loading Image" : "No Image"
                cell.cardImageView.isHidden = true
            }
            cell.configureCost(from: sideboardCard.manaCost?.createManaCostImages())
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "CardDetailViewController") as? CardDetailViewController {
            vc.deck = deck
            let section = isCommander ? indexPath.section - 1 : indexPath.section
            switch section {
            case -1: vc.card = commanders[indexPath.row]
            case 0: vc.card = creatures[indexPath.row]
            case 1: vc.card = spells[indexPath.row]
            case 2: vc.card = lands[indexPath.row]
            default: vc.card = sideboard[indexPath.row]
            }
            vc.shouldUseResult = false
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let card = getCardAtIndexPath(indexPath)
            store.dispatch(RemoveCardFromDeck(card: card))
        }
    }
    
    // MARK: - Supporting Functionality
    
    struct Cell {
        static let creatureCell = "Creature"
        static let spellCell = "Spell"
        static let landCell = "Land"
        static let sideboardCell = "Sideboard"
    }
    
    func getCardAtIndexPath(_ indexPath: IndexPath) -> Card {
        let section = isCommander ? indexPath.section - 1 : indexPath.section
        switch section {
        case -1: return commanders[indexPath.row]
        case 0: return creatures[indexPath.row]
        case 1: return spells[indexPath.row]
        case 2: return lands[indexPath.row]
        default: return sideboard[indexPath.row]
        }
    }
    
}
