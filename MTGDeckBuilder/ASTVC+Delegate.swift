//
//  ASTVC+Delegate.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 1/5/17.
//  Copyright © 2017 Gabriele Pregadio. All rights reserved.
//

import UIKit

extension AdvancedSearchTableViewController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, SwitchDelegate {
    
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
    
    
    // MARK: - UIPickerView Delegate & Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == PickerViewTags.set {
            return 1
        } else {
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        if pickerView.tag == PickerViewTags.set {
            label.text = Filters.sets[row]
        } else {
            switch (component, row) {
            case (0, _): label.text = pickerViewRestrictions[row]
            case (1, 0): label.text = "any"
            default: label.text = "\(row - 1)"
            }
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == PickerViewTags.set {
            return Filters.sets.count
        } else {
            switch (pickerView.tag, component) {
            case (_, 0): return 5
            case (PickerViewTags.cmc, 1): return 17
            case (PickerViewTags.power, 1): return 17
            case (PickerViewTags.toughness, 1): return 17
            default: return 0
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case PickerViewTags.cmc:
            switch (component, row) {
            case (0, _): cmcRestriction = pickerViewRestrictions[row]
            case (1, 0): cmc = "any"
            default: cmc = "\(row - 1)"
            }
        case PickerViewTags.power:
            switch (component, row) {
            case (0, _): powerRestriction = pickerViewRestrictions[row]
            case (1, 0): power = "any"
            default: power = "\(row - 1)"
            }
        case PickerViewTags.toughness:
            switch (component, row) {
            case (0, _): toughnessRestriction = pickerViewRestrictions[row]
            case (1, 0): toughness = "any"
            default: toughness = "\(row - 1)"
            }
        case PickerViewTags.set:
            set = Filters.sets[row]
        default: return
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Switch Delegate Methods
    
    func switchDidToggle(to value: Bool, tag: Int) {
        switch tag {
        case SwitchTags.matchColorsExactly: matchColorsExactly = value
        case SwitchTags.andColors: andColors = value
        case SwitchTags.andTypes: andTypes = value
        case SwitchTags.hasImage: mustHaveImage = value
        default: return
        }
    }
    
}
