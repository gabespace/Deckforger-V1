//
//  DeckListViewController
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/28/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import UIKit
import Alamofire
import ReSwift

class DeckListViewController: UIViewController, StoreSubscriber {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var decks = [Deck]()
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Decks"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Decks", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: self, action: #selector(showSettings))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDeck))
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
    
    @objc private func showSettings() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SettingsTableViewController") as? SettingsTableViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func addDeck() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "EditDeckTableViewController") as? EditDeckTableViewController {
            vc.isCreatingNewDeck = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - StoreSubscriber Delegate Methods
    
    func newState(state: State) {
        if let error = state.error {
            switch error {
            case .loadingError(let description): present(appDelegate.errorAlert(description: description, title: "Loading Error"), animated: true)
            case .savingError(let description): present(appDelegate.errorAlert(description: description, title: "Saving Error"), animated: true)
            case .otherError(let description): present(appDelegate.errorAlert(description: description, title: nil), animated: true)
            }
            return
        }
        
        self.decks = state.decks
        tableView.reloadData()
    }
    
}