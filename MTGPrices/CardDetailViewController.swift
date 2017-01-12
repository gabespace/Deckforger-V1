//
//  CardDetailViewController.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/5/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import UIKit
import ReSwift

/// This view controller is used to display both `Card` and `CardResult` types based on its stored property `shouldUseResult`.
class CardDetailViewController: UIViewController, StoreSubscriber {

    // MARK: - Properties
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /// Used to determine whether the data source should be of type `CardResult` (true) or `Card` (false).
    var shouldUseResult = true
    
    var deck: Deck!
    var cardResult: CardResult?
    var card: Card?
    
    lazy var type: String = {
       return self.cardResult?.type ?? self.card!.type
    }()
    
    lazy var name: String = {
        return self.cardResult?.name ?? self.card!.name
    }()
    
    lazy var isCommander: Bool = {
        return self.card?.isCommander ?? false
    }()
    
    lazy var layout: String = {
        return self.cardResult?.layout ?? self.card!.layout
    }()
    
    lazy var id: String = {
        return self.cardResult?.id ?? self.card!.id
    }()
    
    lazy var manaCost: String? = {
        return self.shouldUseResult ? self.cardResult!.manaCost : self.card!.manaCost
    }()
    
    lazy var text: String? = {
        return self.shouldUseResult ? self.cardResult!.text : self.card!.text
    }()
    
    lazy var flavor: String? = {
        return self.shouldUseResult ? self.cardResult!.flavor : self.card!.flavor
    }()
    
    lazy var set: String = {
        return self.cardResult?.setName ?? self.card!.setName
    }()
    
    lazy var power: String? = {
        return self.shouldUseResult ? self.cardResult!.power : self.card!.power
    }()

    lazy var toughness: String? = {
        return self.shouldUseResult ? self.cardResult!.toughness : self.card!.toughness
    }()
    
    var tableViewData = Array<String>(repeatElement("", count: Sections.names.count))
    
    var mainImage: UIImage?
    
    var flippedCard: CardResult?
    var flippedImage: UIImage?
    var waitingForFlippedResult = false
    var isFlipped = false
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var imageUnavailableLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: CorneredImageView!
    @IBOutlet weak var sideboardButton: UIButton!
    @IBOutlet weak var decrementSideboardButton: UIButton!
    @IBOutlet weak var makeCommanderButton: UIButton!
    @IBOutlet weak var deckCountButton: UIButton!
    @IBOutlet weak var sideCountButton: UIButton!
    
    
    // MARK: - IBActions
    
    @IBAction func makeCommanderButtonPressed(_ sender: UIButton) {
        guard !sender.isHidden else { return }
        
        if sender.titleLabel!.text == "Make Commander" {
            store.dispatch(MakeCardCommander(deck: deck, card: card, cardResult: cardResult))
            makeCommanderButton.setTitle("Remove as Commander", for: .normal)
        } else {
            store.dispatch(UnmakeCardCommander(deck: deck, card: card, cardResult: cardResult))
            makeCommanderButton.setTitle("Make Commander", for: .normal)
        }
    }
    
    @IBAction func addToSideboardButtonPressed(_ sender: UIButton) {
        if shouldUseResult {
            store.dispatch(AddCardResultToSideboard(deck: deck, card: cardResult!, amount: 1))
        } else {
            if !card!.isSideboard {
                store.dispatch(AddMainboardCardToSideboard(deck: deck, mainboardCard: card!, amount: 1))
            } else {
                store.dispatch(IncrementSideboardCardAmount(deck: deck, card: card!, amount: 1))
            }
        }
    }

    @IBAction func removeFromSideboardButtonPressed(_ sender: UIButton) {
        store.dispatch(DecrementSideboardCardAmount(deck: deck, cardId: id, amount: 1))
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        if shouldUseResult {
            store.dispatch(AddCardResultToDeck(deck: deck, card: cardResult!, amount: 1))
        } else {
            if card!.isSideboard {
                store.dispatch(AddSideboardCardToDeck(deck: deck, sideboardCard: card!, amount: 1))
            } else {
                store.dispatch(IncrementMainboardCardAmount(deck: deck, card: card!, amount: 1))
            }
        }
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        store.dispatch(DecrementMainboardCardAmount(deck: deck, cardId: id, amount: 1))
    }
    
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        imageView.clipsToBounds = true
        
        deckCountButton.isUserInteractionEnabled = false
        sideCountButton.isUserInteractionEnabled = false
        
        title = card?.name ?? cardResult?.name
        
        if deck.format != "Commander" {
            makeCommanderButton.isHidden = true
        } else if !type.contains("Creature") && !type.contains("Planeswalker") {
            makeCommanderButton.isHidden = true
        } else if isCommander {
            makeCommanderButton.setTitle("Remove as Commander", for: .normal)
        } else {
            makeCommanderButton.setTitle("Make Commander", for: .normal)
        }
        
        // Fetch/display main image.
        spinner.hidesWhenStopped = true
        imageUnavailableLabel.isHidden = true
        spinner.startAnimating()
        if let imageUrl = cardResult?.imageUrl {
            // Download card result image.
            fetchMainImage(from: imageUrl)
        } else if !shouldUseResult && card!.imageData == nil {
            // No image.
            spinner.stopAnimating()
            imageUnavailableLabel.isHidden = false
            imageView.isHidden = true
        } else if !shouldUseResult && !card!.isDownloadingImage {
            // Display existing card image.
            mainImage = UIImage(data: card!.imageData! as Data)
            image = mainImage
            spinner.stopAnimating()
        } else if !shouldUseResult && card!.isDownloadingImage {
            // Card image is being downloaded - keep animating spinner.
        } else {
            // No image.
            spinner.stopAnimating()
            imageUnavailableLabel.isHidden = false
            imageView.isHidden = true
        }
        
        // Fetch flip card & its image.
        if layout == "double-faced" {
            var parameters: [String: Any] = [:]
            parameters["name"] = getFlippedName()
            waitingForFlippedResult = true
            store.dispatch(searchForAdditionalCardsActionCreator(url: "https://api.magicthegathering.io/v1/cards", parameters: parameters))
        }
        
        getDeckCount()
        displayMainSideInfo()
        
        if !deck.hasSideboard {
            sideboardButton.isHidden = true
            decrementSideboardButton.isHidden = true
            sideCountButton.isHidden = true
            toolBar.items!.remove(at: 7)
            toolBar.items!.remove(at: 6)
            toolBar.items!.remove(at: 5)
        } else {
            toolBar.items!.removeFirst()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.dispatch(UpdateCardReference(deck: deck, cardId: id))
        store.unsubscribe(self)
    }
    
    
    // MARK: - Methods
    
    func displayFlipButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "flip"), style: .plain, target: self, action: #selector(flipButtonPressed))
    }
    
    func flipButtonPressed() {
        isFlipped ? displayMainSideInfo() : displayFlipSideInfo()
        isFlipped = !isFlipped
        tableView.reloadData()
    }
    
    private func mainImageDownloadComplete() {
        if !shouldUseResult && spinner.isAnimating {
            mainImage = UIImage(data: card!.imageData! as Data)
            image = mainImage
            spinner.stopAnimating()
        }
    }
    
    private func displayFlipSideInfo() {
        tableViewData[0] = flippedCard!.name
        tableViewData[1] = ""
        tableViewData[2] = flippedCard!.type!
        tableViewData[3] = (flippedCard!.power ?? "") + "/" + (flippedCard!.toughness ?? "")
        tableViewData[4] = flippedCard!.setName
        tableViewData[5] = flippedCard!.text ?? ""
        tableViewData[6] = flippedCard!.flavor ?? ""
        image = flippedImage
    }
    
    private func displayMainSideInfo() {
        tableViewData[0] = name
        tableViewData[1] = manaCost?.withoutBraces ?? ""
        tableViewData[2] = type
        tableViewData[3] = (power ?? "") + "/" + (toughness ?? "")
        tableViewData[4] = set
        tableViewData[5] = text ?? ""
        tableViewData[6] = flavor ?? ""
        image = mainImage
    }
    
    private func fetchMainImage(from urlString: String) {
        let cardUrl = URL(string: urlString)!
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            if let data = try? Data(contentsOf: cardUrl) {
                DispatchQueue.main.async {
                    let mainImage = UIImage(data: data)
                    self?.spinner.stopAnimating()
                    self?.image = mainImage
                    self?.mainImage = mainImage
                }
            } else {
                DispatchQueue.main.async {
                    self?.spinner.stopAnimating()
                    self?.imageUnavailableLabel.isHidden = false
                    self?.imageView.isHidden = true
                }
            }
        }
    }
    
    private func fetchFlipImage(from urlString: String) {
        let cardUrl = URL(string: urlString)!
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            if let data = try? Data(contentsOf: cardUrl) {
                DispatchQueue.main.async {
                    self?.flippedImage = UIImage(data: data)
                    self?.displayFlipButton()
                }
            }
        }
    }
    
    private func getDeckCount() {
        let request = Card.createFetchRequest()
        request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == false", deck.id, id)
        if let cards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
            if !cards.isEmpty {
                deckCountButton.setTitle("Main: \(cards[0].amount)", for: .normal)
            } else {
                deckCountButton.setTitle("Main: 0", for: .normal)
            }
        } else {
            print("error fetching card count in deck")
        }
    }
    
    private func getSideboardCount() {
        guard deck.hasSideboard else { return }
        
        let request = Card.createFetchRequest()
        request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == true", deck.id, id)
        if let cards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
            if !cards.isEmpty {
                sideCountButton.setTitle("Side: \(cards[0].amount)", for: .normal)
            } else {
                sideCountButton.setTitle("Side: 0", for: .normal)
            }
        } else {
            print("error fetching card count in deck")
        }
    }
    
    private func getFlippedName() -> String {
        var flippedName: String
        if shouldUseResult {
            if cardResult!.names![0] == cardResult!.name {
                flippedName = cardResult!.names![1]
            } else {
                flippedName = cardResult!.names![0]
            }
        } else {
            if card!.names!.flippedNames()![0] == card!.name {
                flippedName = card!.names!.flippedNames()![1]
            } else {
                flippedName = card!.names!.flippedNames()![0]
            }
        }
        return flippedName
    }

    
    // MARK: - StoreSubscriber Delegate Methods
    
    func newState(state: State) {
        getDeckCount()
        getSideboardCount()
        
        if !state.isDownloadingImages {
            mainImageDownloadComplete()
        }
        
        if waitingForFlippedResult && !state.isLoading {
            waitingForFlippedResult = false
            if state.additionalCardResults!.isSuccess {
                flippedCard = state.additionalCardResults!.value!.cards[0]
                if let imageUrl = flippedCard?.imageUrl {
                    fetchFlipImage(from: imageUrl)
                }
            } else {
                print("error retrieving card - deal with this")
            }
        }
    }
    
}
