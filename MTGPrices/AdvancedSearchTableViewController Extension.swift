//
//  AdvancedSearchTableViewController Extension.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/2/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import UIKit

extension AdvancedSearchTableViewController {
    
    // MARK: - UITableView Data Source & Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Filters.names[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (Sections.cmc, 1): return isPickingCmc ? CellHeights.pickerCell : 0
        case (Sections.pt, 1): return isPickingPower ? CellHeights.pickerCell : 0
        case (Sections.pt, 3): return isPickingToughness ? CellHeights.pickerCell : 0
        default: return CellHeights.normalCell
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Filters.names.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Sections.name: return 1
        case Sections.cmc: return 2
        case Sections.rulesText: return 1
        case Sections.color: return Filters.colors.count + 2
        case Sections.type: return Filters.types.count + 1
        case Sections.supertype: return Filters.supertypes.count
        case Sections.subtype: return 1
        case Sections.pt: return 4
        case Sections.rarity: return Filters.rarities.count
        case Sections.format: return Filters.formats.count
        case Sections.hasImage: return 1
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
        case Sections.cmc:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.rangeCell, for: indexPath) as! RangeTableViewCell
                cell.filterText.text = "CMC is"
                cell.amountText.text = cmcRestriction + cmc
                cell.amountText.textColor = isPickingCmc ? UIColor.red : UIColor.black
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.pickerCell, for: indexPath) as! PickerTableViewCell
                cell.pickerView.tag = PickerViewTags.cmc
                cell.pickerView.delegate = self
                cell.pickerView.dataSource = self
                cell.pickerView.selectRow(pickerViewRestrictions.index(of: cmcRestriction)!, inComponent: 0, animated: false)
                cell.pickerView.selectRow((Int(cmc) ?? -1) + 1, inComponent: 1, animated: false)
                return cell
            }
        case Sections.rulesText:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.textCell, for: indexPath) as! TextTableViewCell
            cell.textField.delegate = self
            cell.textField.text = rulesText
            cell.textField.tag = ButtonTags.text
            cell.textField.placeholder = "Ex. Flying, Meld, Draw a card"
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
                cell.label.text = "AND instead of OR"
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
        case Sections.type:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.constraintCell, for: indexPath) as! ConstraintTableViewCell
                cell.label.text = "AND instead of OR"
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
            cell.textField.placeholder = "Ex. Aura, Goblin, Equipment"
            cell.textField.autocorrectionType = .no
            cell.textField.autocapitalizationType = .sentences
            return cell
        case Sections.pt:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.rangeCell, for: indexPath) as! RangeTableViewCell
                cell.filterText.text = "Power is"
                cell.amountText.text = powerRestriction + power
                cell.amountText.textColor = isPickingPower ? UIColor.red : UIColor.black
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.pickerCell, for: indexPath) as! PickerTableViewCell
                cell.pickerView.tag = PickerViewTags.power
                cell.pickerView.delegate = self
                cell.pickerView.dataSource = self
                cell.pickerView.selectRow(pickerViewRestrictions.index(of: powerRestriction)!, inComponent: 0, animated: false)
                cell.pickerView.selectRow((Int(power) ?? -1) + 1, inComponent: 1, animated: false)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.rangeCell, for: indexPath) as! RangeTableViewCell
                cell.filterText.text = "Toughness is"
                cell.amountText.text = toughnessRestriction + toughness
                cell.amountText.textColor = isPickingToughness ? UIColor.red : UIColor.black
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.pickerCell, for: indexPath) as! PickerTableViewCell
                cell.pickerView.tag = PickerViewTags.toughness
                cell.pickerView.delegate = self
                cell.pickerView.dataSource = self
                cell.pickerView.selectRow(pickerViewRestrictions.index(of: toughnessRestriction)!, inComponent: 0, animated: false)
                cell.pickerView.selectRow((Int(toughness) ?? -1) + 1, inComponent: 1, animated: false)
                return cell
            }
        case Sections.rarity:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filterCell, for: indexPath)
            let rarity = Filters.rarities[indexPath.row]
            cell.textLabel?.text = rarity
            cell.accessoryType = rarities.contains(rarity) ? .checkmark : .none
            return cell
        case Sections.format:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.filterCell, for: indexPath)
            let format = Filters.formats[indexPath.row]
            cell.textLabel?.text = format
            cell.accessoryType = formats.contains(format) ? .checkmark : .none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.constraintCell, for: indexPath) as! ConstraintTableViewCell
            cell.label.text = "Must Have Image"
            cell.selectionSwitch.tag = SwitchTags.hasImage
            cell.switchDelegate = self
            cell.selectionSwitch.isOn = mustHaveImage
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case Sections.cmc:
            if indexPath.row == 1 { return }
            isPickingCmc = !isPickingCmc
            UIView.animate(withDuration: 0.3) { [unowned self] in
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: Sections.cmc), IndexPath(row: 1, section: Sections.cmc)], with: .automatic)
            }
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
        case Sections.pt:
            if indexPath.row == 0 {
                isPickingPower = !isPickingPower
                UIView.animate(withDuration: 0.3) { [unowned self] in
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: Sections.pt), IndexPath(row: 1, section: Sections.pt)], with: .automatic)
                }
            } else if indexPath.row == 2 {
                isPickingToughness = !isPickingToughness
                UIView.animate(withDuration: 0.3) { [unowned self] in
                    self.tableView.reloadRows(at: [IndexPath(row: 2, section: Sections.pt), IndexPath(row: 3, section: Sections.pt)], with: .automatic)
                }
            } else {
                return
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
        static let rangeCell = "Range Cell"
        static let pickerCell = "Picker Cell"
    }
    
    struct CellHeights {
        static let normalCell: CGFloat = 44
        static let pickerCell: CGFloat = 219
    }
    
    struct ButtonTags {
        static let name = 0
        static let cmcRestriction = 10
        static let cmcAmount = 11
        static let text = 2
        static let subtype = 6
    }
    
    struct PickerViewTags {
        static let cmc = 0
        static let power = 1
        static let toughness = 2
    }
    
    struct SwitchTags {
        static let matchColorsExactly = 0
        static let andColors = 1
        static let andTypes = 2
        static let hasImage = 3
    }
    
    struct Filters {
        static let names = ["Name", "Converted Mana Cost", "Rules Text", "Color", "Type", "Supertype", "Subtype", "Power & Toughness", "Rarity", "Format", nil]
        static let colors = ["White", "Blue", "Red", "Black", "Green"]
        static let types = ["Artifact", "Creature", "Enchantment", "Instant", "Land", "Planeswalker", "Sorcery", "Tribal"]
        static let supertypes = ["Legendary", "Snow"]
        static let rarities = ["Mythic Rare", "Rare", "Uncommon", "Common", "Basic Land"]
        static let formats = ["Standard", "Modern", "Legacy", "Vintage", "Commander"]
    }
    
    struct Sections {
        static let name = 0
        static let cmc = 1
        static let rulesText = 2
        static let color = 3
        static let type = 4
        static let supertype = 5
        static let subtype = 6
        static let pt = 7
        static let rarity = 8
        static let format = 9
        static let hasImage = 10
    }
    
}
