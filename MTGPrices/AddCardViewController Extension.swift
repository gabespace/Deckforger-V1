//
//  AddCardViewController Extension.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/30/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import UIKit

extension AddCardViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    // MARK: - Computed Properties
    
    var hasMoreResults: Bool {
        if let totalCount = headers?["total-count"] as? String {
            return cardResults.count < Int(totalCount)!
        } else {
            return false
        }
    }
    
    
    // MARK: - UISearchBarDelegate Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let cardName = searchBar.text else { return }
        
        currentPage = 1
        isDownloadingInitialResults = true
        cardResults.removeAll()
        tableView.reloadData()
        parameters.removeAll()
        searchBar.resignFirstResponder()
        parameters["name"] = cardName
        parameters["orderBy"] = sortFields[searchBar.selectedScopeButtonIndex]
        isDirty = true
        store.dispatch(searchForCardsActionCreator(url: "https://api.magicthegathering.io/v1/cards", parameters: parameters, previousResults: nil, currentPage: currentPage))
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        parameters["orderBy"] = sortFields[searchBar.selectedScopeButtonIndex]
        
        if !cardResults.isEmpty {
            tableView.setContentOffset(CGPoint.zero, animated: false)
            currentPage = 1
            isDownloadingInitialResults = true
            cardResults.removeAll()
            tableView.reloadData()
            isDirty = true
            store.dispatch(searchForCardsActionCreator(url: "https://api.magicthegathering.io/v1/cards", parameters: parameters, previousResults: nil, currentPage: currentPage))
        }
    }
    
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isDownloadingInitialResults {
            return 1
        } else if hasMoreResults {
            return cardResults.count + 1
        } else {
            return max(cardResults.count, 1)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isDownloadingInitialResults {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.loadingCell, for: indexPath)
            cell.textLabel?.text = "Retrieving Cards..."
            return cell
        } else if cardResults.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cell.loadingCell, for: indexPath)
            cell.textLabel?.text = "No Results"
            return cell
        } else {
            if indexPath.row == cardResults.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.showMoreResultsCell, for: indexPath)
                cell.textLabel?.text = "Show More Results"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: Cell.resultCell, for: indexPath) as! CardResultTableViewCell
                let result = cardResults[indexPath.row]
                cell.nameLabel.text = result.name
                cell.subtitleLabel.text = "\(result.type!), Set: \(result.set!)"
                cell.configureCost(from: result.manaCost?.createManaCostImages())
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !rowIsSelected else { return }
        guard !cardResults.isEmpty else { return }
        
        rowIsSelected = true
        self.searchBar.resignFirstResponder()
        
        if indexPath.row == cardResults.count{
            tableView.cellForRow(at: indexPath)!.textLabel?.text = "Retrieving Cards..."
            tableView.deselectRow(at: indexPath, animated: true)
            currentPage += 1
            isDownloadingAdditionalPages = true
            isDirty = true
            store.dispatch(searchForCardsActionCreator(url: "https://api.magicthegathering.io/v1/cards", parameters: parameters, previousResults: cardResults, currentPage: currentPage))
        } else {
            rowIsSelected = false
            let card = cardResults[indexPath.row]
            if let vc = storyboard?.instantiateViewController(withIdentifier: "CardDetailViewController") as? CardDetailViewController {
                vc.cardResult = card
                vc.deck = deck
                vc.shouldUseResult = true
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    // MARK: - Supporting Functionality
    
    struct Cell {
        static let resultCell = "Card Result"
        static let loadingCell = "Loading"
        static let showMoreResultsCell = "Show More Results"
    }
}
