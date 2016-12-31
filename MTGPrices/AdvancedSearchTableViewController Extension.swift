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
        case Sections.name: return 1
        case Sections.rulesText: return 1
        case Sections.color: return Filters.colors.count + 2
        case Sections.type: return Filters.types.count + 1
        case Sections.supertype: return Filters.supertypes.count
        case Sections.subtype: return 1
        case Sections.rarity: return Filters.rarities.count
        case Sections.format: return Filters.formats.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Sections.name:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.textCell, for: indexPath) as! TextTableViewCell
            cell.textField.delegate = self
            cell.textField.text = cardName
            cell.textField.tag = ButtonTags.name
            cell.textField.placeholder = "Card Name"
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .sentences
            return cell
        case Sections.rulesText:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.textCell, for: indexPath) as! TextTableViewCell
            cell.textField.delegate = self
            cell.textField.text = rulesText
            cell.textField.tag = ButtonTags.text
            cell.textField.placeholder = "Ex. Flying, Meld, Draw a card..."
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .sentences
            return cell
        case Sections.color:
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
        case Sections.type: // Type Cell
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
        case Sections.supertype:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filterCell, for: indexPath)
            let supertype = Filters.supertypes[indexPath.row]
            cell.textLabel?.text = supertype
            cell.accessoryType = supertypes.contains(supertype) ? .checkmark : .none
            return cell
        case Sections.subtype:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.textCell, for: indexPath) as! TextTableViewCell
            cell.textField.delegate = self
            cell.textField.text = subtype
            cell.textField.tag = ButtonTags.subtype
            cell.textField.placeholder = "Ex. Aura, Goblin, Equipment..."
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .sentences
            return cell
        case Sections.rarity:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filterCell, for: indexPath)
            let rarity = Filters.rarities[indexPath.row]
            cell.textLabel?.text = rarity
            cell.accessoryType = rarities.contains(rarity) ? .checkmark : .none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filterCell, for: indexPath)
            let format = Filters.formats[indexPath.row]
            cell.textLabel?.text = format
            cell.accessoryType = formats.contains(format) ? .checkmark : .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case Sections.color:
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
        case Sections.type:
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
        case Sections.supertype:
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell.accessoryType == .checkmark {
                    supertypes.remove(at: supertypes.index(of: Filters.supertypes[indexPath.row])!)
                    cell.accessoryType = .none
                } else {
                    supertypes.append(Filters.supertypes[indexPath.row])
                    cell.accessoryType = .checkmark
                }
            }
        case Sections.rarity:
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell.accessoryType == .checkmark {
                    rarities.remove(at: rarities.index(of: Filters.rarities[indexPath.row])!)
                    cell.accessoryType = .none
                } else {
                    rarities.append(Filters.rarities[indexPath.row])
                    cell.accessoryType = .checkmark
                }
            }
        case Sections.format:
            if let cell = tableView.cellForRow(at: indexPath) {
                if cell.accessoryType == .checkmark {
                    formats.remove(at: formats.index(of: Filters.formats[indexPath.row])!)
                    cell.accessoryType = .none
                } else {
                    formats.append(Filters.formats[indexPath.row])
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
        static let subtype = 5
    }
    
    struct SwitchTags {
        static let matchColorsExactly = 0
        static let andColors = 1
        static let andTypes = 2
    }
    
    struct Filters {
        static let names = ["Name", "Rules Text", "Color", "Type", "Supertype", "Subtype", "Rarity", "Format"]
        static let colors = ["White", "Blue", "Red", "Black", "Green"]
        static let types = ["Artifact", "Creature", "Enchantment", "Instant", "Land", "Planeswalker", "Sorcery", "Tribal"]
        static let supertypes = ["Legendary", "Snow"]
        static let rarities = ["Mythic Rare", "Rare", "Uncommon", "Common", "Basic Land"]
        static let formats = ["Standard", "Modern", "Legacy", "Vintage", "Commander"]
    }
    
    struct Sections {
        static let name = 0
        static let rulesText = 1
        static let color = 2
        static let type = 3
        static let supertype = 4
        static let subtype = 5
        static let rarity = 6
        static let format = 7
    }
    
}
