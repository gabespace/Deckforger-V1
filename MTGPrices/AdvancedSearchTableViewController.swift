//
//  AdvancedSearchTableViewController.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/1/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import UIKit
import ReSwift

class AdvancedSearchTableViewController: UITableViewController, StoreSubscriber {
    
    // MARK: - Stored Properties
    
    var cardName: String?
    var cmcRestriction = "equal to "
    var cmc = "any"
    var rulesText: String?
    var subtype: String?
    var colors = [String]()
    var supertypes = [String]()
    var types = [String]()
    var powerRestriction = "equal to "
    var power = "any"
    var toughnessRestriction = "equal to "
    var toughness = "any"
    var rarities = [String]()
    var formats = [String]()
    
    var matchColorsExactly = false
    var andColors = false
    var andTypes = false
    var mustHaveImage = false
    
    var sectionBeingEdited: Int?
    var isPickingCmc = false
    var isPickingPower = false
    var isPickingToughness = false
    
    let pickerViewRestrictions = ["less than ", "less than or equal to ", "equal to ", "greater than or equal to ", "greater than "]
    let restrictionTerms = ["lt", "lte", "", "gte", "gt"]
    
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filters"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
    }
    
    
    // MARK: - Methods
    
    @objc private func searchButtonTapped() {
        if let section = sectionBeingEdited {
            // User is editing a text field.
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: section)) as! TextTableViewCell
            cell.textField.resignFirstResponder()
        }
        store.dispatch(PrepareForSearch(parameters: createParameters()))
        _ = navigationController!.popViewController(animated: true)
    }
    
    private func createParameters() -> [String: Any] {
        var parameters = [String: Any]()
        
        parameters["orderBy"] = "name"
        
        if let name = cardName {
            parameters["name"] = name
        }
        if let rules = rulesText {
            parameters["text"] = rules
        }
        if let subtype = subtype {
            parameters["subtypes"] = subtype
        }
        
        if !colors.isEmpty {
            var colorString: String
            switch (matchColorsExactly, andColors) {
            case (true, _):
                colorString = colors.joined(separator: ",")
                colorString.insert("\"", at: colorString.startIndex)
                colorString.insert("\"", at: colorString.endIndex)
            case (false, true):
                colorString = colors.joined(separator: ",")
            case (false, false):
                colorString = colors.joined(separator: "|")
            }
            
            parameters["colors"] = colorString
        }
        
        if !types.isEmpty {
            parameters["types"] = types.joined(separator: andTypes ? "," : "|")
        }
        
        if !supertypes.isEmpty {
            parameters["supertypes"] = supertypes.joined(separator: ",")
        }
        
        if !rarities.isEmpty {
            parameters["rarity"] = rarities.joined(separator: "|")
        }
        
        if !formats.isEmpty {
            parameters["gameFormat"] = formats.joined(separator: "|")
        }
        
        if let cost = Int(cmc) {
            let restriction = restrictionTerms[pickerViewRestrictions.index(of: cmcRestriction)!]
            parameters["cmc"] = restriction + "\(cost)"
        }
        
        if let p = Int(power) {
            let restriction = restrictionTerms[pickerViewRestrictions.index(of: powerRestriction)!]
            parameters["power"] = restriction + "\(p)"
        }
        
        if let t = Int(toughness) {
            let restriction = restrictionTerms[pickerViewRestrictions.index(of: toughnessRestriction)!]
            parameters["toughness"] = restriction + "\(t)"
        }
        
        if mustHaveImage {
            parameters["contains"] = "imageUrl"
        } else {
            parameters.removeValue(forKey: "contains")
        }
        
        return parameters
    }
    
    private func configureInitialSelections(_ initialParameters: [String: Any]?) {
        guard let parameters = initialParameters else { return }
        
        cardName = parameters["name"] as? String
        rulesText = parameters["text"] as? String
        subtype = parameters["subtypes"] as? String
        
        if let initialColors = parameters["colors"] as? String {
            if initialColors.contains("\"") {
                matchColorsExactly = true
            }
            if initialColors.contains(",") {
                colors = initialColors.replacingOccurrences(of: "\"", with: "").components(separatedBy: ",")
                andColors = true
            } else {
                colors = initialColors.replacingOccurrences(of: "\"", with: "").components(separatedBy: "|")
            }
        }
        
        if let initialTypes = parameters["types"] as? String {
            if initialTypes.contains(",") {
                types = initialTypes.components(separatedBy: ",")
                andTypes = true
            } else {
                types = initialTypes.components(separatedBy: "|")
            }
        }
        
        if let initialSupertypes = parameters["supertypes"] as? String {
            supertypes = initialSupertypes.components(separatedBy: ",")
        }
        
        if let initialRarities = parameters["rarity"] as? String {
            rarities = initialRarities.components(separatedBy: "|")
        }
        
        if let initialFormats = parameters["gameFormat"] as? String {
            formats = initialFormats.components(separatedBy: "|")
        }
        
        if let initialCmc = parameters["cmc"] as? String {
            if initialCmc.isANumber {
                cmcRestriction = "equal to "
                cmc = initialCmc
            } else {
                let components = initialCmc.restrictionComponents
                cmcRestriction = pickerViewRestrictions[restrictionTerms.index(of: components[0])!]
                cmc = components[1]
            }
        }
        
        if let initialPower = parameters["power"] as? String {
            if initialPower.isANumber {
                powerRestriction = "equal to "
                power = initialPower
            } else {
                let components = initialPower.restrictionComponents
                powerRestriction = pickerViewRestrictions[restrictionTerms.index(of: components[0])!]
                power = components[1]
            }
        }
        
        if let initialToughness = parameters["toughness"] as? String {
            if initialToughness.isANumber {
                toughnessRestriction = "equal to "
                toughness = initialToughness
            } else {
                let components = initialToughness.restrictionComponents
                toughnessRestriction = pickerViewRestrictions[restrictionTerms.index(of: components[0])!]
                toughness = components[1]
            }
        }
        
        if parameters["contains"] as? String == "imageUrl" {
            mustHaveImage = true
        }
    }
    
    
    // MARK: - StoreSubscriber Delegate Methods
    
    func newState(state: State) {
        configureInitialSelections(state.parameters)
    }
    
}

extension String {
    var isANumber: Bool {
        return Int(self) != nil
    }
    
    var restrictionComponents: [String] {
        for (offset, char) in self.characters.enumerated() {
            if String(char).isANumber {
                return [self.substring(to: self.index(self.startIndex, offsetBy: offset)), self.substring(from: self.index(self.startIndex, offsetBy: offset))]
            }
        }
        return []
    }
}
