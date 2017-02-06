//
//  DeckViewController.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 11/29/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//
import UIKit
import ReSwift
import Charts

class DeckViewController: UIViewController, StoreSubscriber {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var statsScrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    
    
    // MARK: - Properties
    
    let colorPieChartView = PieChartView()
    let typePieChartView = PieChartView()
    let costBarChartView = BarChartView()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var deck: Deck!
    var cards = [Card]()
    lazy var isCommander: Bool = {
       return self.deck.format == "Commander"
    }()
    
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = deck.name
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Deck", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(searchForCards)),
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareDeck))
        ]
        
        NotificationCenter.default.addObserver(self, selector: #selector(redraw), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items![0]
        
        colorPieChartView.delegate = self
        typePieChartView.delegate = self
        costBarChartView.delegate = self
        
        statsScrollView.delegate = self
        statsScrollView.isHidden = true
        statsScrollView.backgroundColor = Colors.background
        
        statsScrollView.addSubview(colorPieChartView)
        statsScrollView.addSubview(typePieChartView)
        statsScrollView.addSubview(costBarChartView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
        setColorPieChartData()
        setTypePieChartData()
        setCostBarChartData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        redraw()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        store.unsubscribe(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        store.dispatch(ReceivedMemoryWarning(restorationIdentifier: restorationIdentifier!))
    }
    
    
    // MARK: - Methods
    
    func redraw() {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            colorPieChartView.frame = CGRect(x: 0, y: 0, width: statsScrollView.frame.width * 0.33, height: statsScrollView.frame.height)
            typePieChartView.frame = CGRect(x: colorPieChartView.frame.maxX, y: 0, width: statsScrollView.frame.width * 0.33, height: statsScrollView.frame.height)
            costBarChartView.frame = CGRect(x: typePieChartView.frame.maxX, y: 0, width: statsScrollView.frame.width * 0.34, height: statsScrollView.frame.height)
        } else {
            colorPieChartView.frame = CGRect(x: 0, y: 0, width: statsScrollView.frame.width, height: statsScrollView.frame.height * 0.33)
            typePieChartView.frame = CGRect(x: 0, y: colorPieChartView.frame.maxY, width: statsScrollView.frame.width, height: statsScrollView.frame.height * 0.33)
            costBarChartView.frame = CGRect(x: 0, y: typePieChartView.frame.maxY, width: statsScrollView.frame.width, height: statsScrollView.frame.height * 0.34)
        }
        statsScrollView.contentSize = statsScrollView.frame.size
    }
    
    @objc private func shareDeck() {
        var deckString = "\(deck.name) (Main: \(deck.mainboardCount)"
        if deck.hasSideboard {
            deckString += ", Side: \(deck.sideboardCount))\n"
        } else {
            deckString += ")\n"
        }
        if isCommander {
            for commander in commanders {
                deckString += "\(commander.amount) \(commander.name)\n"
            }
        }
        for creature in creatures {
            deckString += "\(creature.amount) \(creature.name)\n"
        }
        for spell in spells {
            deckString += "\(spell.amount) \(spell.name)\n"
        }
        for land in lands {
            deckString += "\(land.amount) \(land.name)\n"
        }
        if deck.hasSideboard {
            deckString += "Sideboard\n"
            for card in sideboard {
                deckString += "\(card.amount) \(card.name)\n"
            }
        }
        
        let vc = UIActivityViewController(activityItems: [deckString], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?[1]
        present(vc, animated: true)
    }
    
    @objc private func searchForCards() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: StoryboardIdentifiers.addCard.rawValue) as? AddCardViewController {
            vc.deck = deck
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func fetchCards() {
        let cardRequest = Card.createFetchRequest()
        cardRequest.predicate = NSPredicate(format: "deck.id == %@", deck.id)
        if let cards = try? appDelegate.persistentContainer.viewContext.fetch(cardRequest) {
            self.cards = cards
            for card in cards {
                if !card.isDownloadingImage && card.imageUrl != nil && card.imageData == nil {
                    store.dispatch(ReDownloadImageForCard(card: card))
                }
            }
            tableView.reloadData()
        } else {
            present(
                errorAlert(description: "Unable to access stored cards for this deck. Please close the app and try again.", title: "Loading Error"),
                animated: true
            )
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    
    // MARK: - StoreSubscriber Delegate Methods
    
    func newState(state: RootState) {
        if let error = state.coreDataState.coreDataError {
            switch error {
            case .loadingError(let description): present(errorAlert(description: description, title: "Loading Error"), animated: true)
            case .savingError(let description): present(errorAlert(description: description, title: "Saving Error"), animated: true)
            case .otherError(let description): present(errorAlert(description: description, title: nil), animated: true)
            }
            return
        }
        
        fetchCards()
        if !state.coreDataState.isDownloadingImages {
            tableView.reloadData()
        }
    }
    
}
