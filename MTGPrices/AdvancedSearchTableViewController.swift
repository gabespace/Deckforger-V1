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
    var rulesText: String?
    var subtype: String?
    var colors = [String]()
    var types = [String]()
    var rarities = [String]()
    
    var matchColorsExactly = false
    var andColors = false
    var andTypes = false
    
    var sectionBeingEdited: Int?
    
    
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
        
        // Colors
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
        
        // Types
        if !types.isEmpty {
            parameters["types"] = types.joined(separator: andTypes ? "," : "|")
        }
        
        // Rarities
        if !rarities.isEmpty {
            parameters["rarity"] = rarities.joined(separator: "|")
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
        
        if let initialRarities = parameters["rarity"] as? String {
            rarities = initialRarities.components(separatedBy: "|")
        }
    }
    
    
    // MARK: - StoreSubscriber Delegate Methods
    
    func newState(state: State) {
        configureInitialSelections(state.parameters)
    }
    
}
