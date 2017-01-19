//
//  AddCardViewController.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/30/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import UIKit
import ReSwift

class AddCardViewController: UIViewController, StoreSubscriber {

    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    // MARK: - Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var deck: Deck!
    var cardResults = [CardResult]()
    var parameters: [String: Any] = [:]
    var headers: [AnyHashable: Any]?
    
    let sortFields = ["name", "colors", "cmc"]
    var rowIsSelected = false
    var isDirty = true
    var isDownloadingInitialResults = false
    var isDownloadingAdditionalPages = false
    var currentPage = 1 {
        didSet {
            parameters["page"] = currentPage
        }
    }
    
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Card Search"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Quick Search", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filters", style: .plain, target: self, action: #selector(advancedSearchButtonTapped))
        
        searchBar.scopeButtonTitles = ["Alphabetical", "Color", "CMC"]
        searchBar.showsScopeBar = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Methods
    
    @objc private func advancedSearchButtonTapped() {
        isDirty = true
        self.searchBar.resignFirstResponder()
        if let vc = storyboard?.instantiateViewController(withIdentifier: "AdvancedSearchTableViewController") as? AdvancedSearchTableViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    // MARK: - StoreSubscriber Delegate Methods
    
    func newState(state: State) {
        guard isDirty else { return }
        
        if let newParameters = state.parameters {
            parameters = newParameters
            searchBar.text = (parameters["name"] as? String) ?? nil
        }
        
        if state.shouldSearch {
            // Just came back from AdvancedSearchViewController with new parameters.
            currentPage = 1
            isDownloadingInitialResults = true
            cardResults.removeAll()
            tableView.reloadData()
            searchBar.selectedScopeButtonIndex = 0
            store.dispatch(searchForCardsActionCreator(url: "https://api.magicthegathering.io/v1/cards", parameters: parameters, previousResults: nil, currentPage: currentPage))
        } else {
            currentPage = state.currentRequestPage
            if let result = state.cardResults {
                isDownloadingInitialResults = false
                isDirty = false
                if result.isSuccess {
                    if isDownloadingAdditionalPages {
                        isDownloadingAdditionalPages = false
                        rowIsSelected = false
                    }
                    cardResults = result.value!.cards
                    headers = result.value!.headers
                    tableView.reloadData()
                } else {
                    if let error = result.error as? ApiError {
                        present(appDelegate.errorAlert(description: error.message), animated: true)
                    }
                    tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.textLabel?.text = "Error Retrieving Cards"
                }
            }
        }
    }
    
}
