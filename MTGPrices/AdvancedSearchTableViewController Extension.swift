//
//  AdvancedSearchTableViewController Extension.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/2/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import UIKit

extension AdvancedSearchTableViewController: UITextFieldDelegate, SwitchDelegate {
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        sectionBeingEdited = textField.tag
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        sectionBeingEdited = nil
        switch textField.tag {
        case ButtonTags.name: cardName = textField.text
        case ButtonTags.text: rulesText = textField.text
        case ButtonTags.subtype: subtype = textField.text
        default: return
        }
    }
    
    
    // MARK: - Switch Delegate Methods
    
    func switchDidToggle(to value: Bool, tag: Int) {
        switch tag {
        case SwitchTags.matchColorsExactly: matchColorsExactly = value
        case SwitchTags.andColors: andColors = value
        case SwitchTags.andTypes: andTypes = value
        default: return
        }
    }
    
    
    // MARK: - UITableView Data Source & Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Filters.names[section]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Filters.names.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return Filters.colors.count + 2
        case 3: return Filters.types.count + 1
        case 4: return 1
        default: return Filters.rarities.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0: // Name Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.textCell, for: indexPath) as! TextTableViewCell
            cell.textField.delegate = self
            cell.textField.text = cardName
            cell.textField.tag = ButtonTags.name
            cell.textField.placeholder = "Card Name"
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .sentences
            return cell
        case 1: // Rules Text Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.textCell, for: indexPath) as! TextTableViewCell
            cell.textField.delegate = self
            cell.textField.text = rulesText
            cell.textField.tag = ButtonTags.text
            cell.textField.placeholder = "Rules Text contains..."
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .sentences
            return cell
        case 2: // Color Cell
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.constraintCell, for: indexPath) as! ConstraintTableViewCell
                cell.label.text = "Match Colors Exactly"
                cell.selectionSwitch.tag = SwitchTags.matchColorsExactly
                cell.switchDelegate = self
                cell.selectionSwitch.isOn = matchColorsExactly
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.constraintCell, for: indexPath) as! ConstraintTableViewCell
                cell.label.text = "AND Colors"
                cell.selectionSwitch.tag = SwitchTags.andColors
                cell.switchDelegate = self
                cell.selectionSwitch.isOn = andColors
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filterCell, for: indexPath)
                let color = Filters.colors[indexPath.row - 2]
                cell.textLabel?.text = color
                cell.accessoryType = colors.contains(color) ? .checkmark : .none
                return cell
            }
        case 3: // Type Cell
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.constraintCell, for: indexPath) as! ConstraintTableViewCell
                cell.label.text = "AND Types"
                cell.selectionSwitch.tag = SwitchTags.andTypes
                cell.switchDelegate = self
                cell.selectionSwitch.isOn = andTypes
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filterCell, for: indexPath)
                let type = Filters.types[indexPath.row - 1]
                cell.textLabel?.text = type
                cell.accessoryType = types.contains(type) ? .checkmark : .none
                return cell
            }
        case 4: // Subtype Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.textCell, for: indexPath) as! TextTableViewCell
            cell.textField.delegate = self
            cell.textField.text = subtype
            cell.textField.tag = ButtonTags.subtype
            cell.textField.placeholder = "Subtype"
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .sentences
            return cell
        default: // Rarity Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filterCell, for: indexPath)
            let rarity = Filters.rarities[indexPath.row]
            cell.textLabel?.text = rarity
            cell.accessoryType = rarities.contains(rarity) ? .checkmark : .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 2: // Color
            if indexPath.row < 2 { return }
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell.accessoryType == .checkmark {
                    colors.remove(at: colors.index(of: Filters.colors[indexPath.row - 2])!)
                    cell.accessoryType = .none
                } else {
                    colors.append(Filters.colors[indexPath.row - 2])
                    cell.accessoryType = .checkmark
                }
            }
        case 3: // Type
            if indexPath.row == 0 { return }
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell.accessoryType == .checkmark {
                    types.remove(at: types.index(of: Filters.types[indexPath.row - 1])!)
                    cell.accessoryType = .none
                } else {
                    types.append(Filters.types[indexPath.row - 1])
                    cell.accessoryType = .checkmark
                }
            }
        case 5: // Rarity
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell.accessoryType == .checkmark {
                    rarities.remove(at: rarities.index(of: Filters.rarities[indexPath.row])!)
                    cell.accessoryType = .none
                } else {
                    rarities.append(Filters.rarities[indexPath.row])
                    cell.accessoryType = .checkmark
                }
            }
        default:
            return
        }
    }
    
    
    
    // MARK: - Supporting Functionality
    
    struct Cell {
        static let textCell = "Text Cell"
        static let filterCell = "Filter Cell"
        static let constraintCell = "Constraint Cell"
    }
    
    struct ButtonTags {
        static let name = 0
        static let text = 1
        static let subtype = 4
    }
    
    struct SwitchTags {
        static let matchColorsExactly = 0
        static let andColors = 1
        static let andTypes = 2
    }
    
    struct Filters {
        static let names = ["Name", "Rules Text", "Color", "Type", "Subtype", "Rarity"]
        static let colors = ["White", "Blue", "Red", "Black", "Green"]
        static let types = ["Artifact", "Creature", "Enchantment", "Instant", "Land", "Legendary", "Planeswalker", "Sorcery"]
        static let rarities = ["Mythic Rare", "Rare", "Uncommon", "Common", "Basic Land"]
    }
    
    
}
