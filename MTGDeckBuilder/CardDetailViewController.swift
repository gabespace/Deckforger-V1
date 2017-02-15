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
    
    lazy var names: [String]? = {
        return self.cardResult?.names ?? self.card?.names?.flippedNames()
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
    
    lazy var rarity: String = {
        return self.cardResult?.rarity ?? self.card!.rarity
    }()
    
    lazy var power: String? = {
        return self.shouldUseResult ? self.cardResult!.power : self.card!.power
    }()

    lazy var toughness: String? = {
        return self.shouldUseResult ? self.cardResult!.toughness : self.card!.toughness
    }()
    
    lazy var imageUrl: URL? = {
        if self.shouldUseResult {
            if let urlString = self.cardResult!.imageUrl {
                return URL(string: urlString)
            }
        } else {
            if let urlString = self.card!.imageUrl {
                return URL(string: urlString)
            }
        }
        return nil
    }()
    
    var tableViewData = Array<String>(repeatElement("", count: Sections.names.count))
    
    var mainImage: UIImage?
    
    var flippedCard: CardResult?
    var flippedImage: UIImage?
    var isFlipped = false
    var fetchFlipSideRequested = false
    
    var image: UIImage? {
        didSet {
            imageView.image = image
            spinner.stopAnimating()
        }
    }
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 50
        }
    }
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var imageUnavailableLabel: UILabel! { didSet { imageUnavailableLabel.isHidden = true } }
    @IBOutlet weak var spinner: UIActivityIndicatorView! { didSet { spinner.hidesWhenStopped = true } }
    @IBOutlet weak var imageView: CorneredImageView! { didSet { imageView.clipsToBounds = true } }
    @IBOutlet weak var sideboardButton: UIButton!
    @IBOutlet weak var decrementSideboardButton: UIButton!
    @IBOutlet weak var makeCommanderButton: UIButton!
    @IBOutlet weak var deckCountButton: UIButton! { didSet { deckCountButton.isUserInteractionEnabled = false } }
    @IBOutlet weak var sideCountButton: UIButton! { didSet { sideCountButton.isUserInteractionEnabled = false } }
    
    
    // MARK: - IBActions
    
    @IBAction func makeCommanderButtonPressed(_ sender: UIButton) {
        guard !sender.isHidden else { return }
        
        if sender.titleLabel!.text == ButtonLabels.makeCommander {
            store.dispatch(MakeCardCommander(deck: deck, card: card, cardResult: cardResult))
            makeCommanderButton.setTitle(ButtonLabels.unmakeCommander, for: .normal)
        } else {
            store.dispatch(UnmakeCardCommander(deck: deck, card: card, cardResult: cardResult))
            makeCommanderButton.setTitle(ButtonLabels.makeCommander, for: .normal)
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        if shouldUseResult {
            store.dispatch(AddCardResultToDeck(deck: deck, card: cardResult!, amount: 1, toSideboard: false))
        } else {
            if card!.isSideboard {
                store.dispatch(AddSideboardCardToMainboard(deck: deck, sideboardCard: card!, amount: 1))
            } else {
                store.dispatch(UpdateCardAmount(deck: deck, cardId: id, amount: 1, isSideboard: false))
            }
        }
    }
    
    @IBAction func addToSideboardButtonPressed(_ sender: UIButton) {
        if shouldUseResult {
            store.dispatch(AddCardResultToDeck(deck: deck, card: cardResult!, amount: 1, toSideboard: true))
        } else {
            if card!.isSideboard {
                store.dispatch(UpdateCardAmount(deck: deck, cardId: id, amount: 1, isSideboard: true))
            } else {
                store.dispatch(AddMainboardCardToSideboard(deck: deck, mainboardCard: card!, amount: 1))
            }
        }
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        store.dispatch(UpdateCardAmount(deck: deck, cardId: id, amount: -1, isSideboard: false))
    }
    
    @IBAction func removeFromSideboardButtonPressed(_ sender: UIButton) {
        store.dispatch(UpdateCardAmount(deck: deck, cardId: id, amount: -1, isSideboard: true))
    }
    
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = name
        
        formatSideboardButtons()
        formatCommanderButton()
        formatMainImage()
        formatFlipCard()
        getDeckCount()
        displayMainSideInfo()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        store.dispatch(ReceivedMemoryWarning(restorationIdentifier: restorationIdentifier!))
    }
    
    
    // MARK: - Methods
    
    private func formatCommanderButton() {
        if deck.format != "Commander" {
            makeCommanderButton.isHidden = true
        } else if !type.contains("Creature") && !type.contains("Planeswalker") {
            makeCommanderButton.isHidden = true
        } else if isCommander {
            makeCommanderButton.setTitle(ButtonLabels.unmakeCommander, for: .normal)
        } else {
            makeCommanderButton.setTitle(ButtonLabels.makeCommander, for: .normal)
        }
    }
    
    private func formatMainImage() {
        guard let imageUrl = imageUrl else {
            imageUnavailableLabel.isHidden = false
            imageView.isHidden = true
            return
        }
        
        spinner.startAnimating()
        
        if shouldUseResult {
            store.dispatch(fetchMainImageActionCreator(url: imageUrl))
        } else {
            if card!.imageData == nil {
                spinner.stopAnimating()
                imageUnavailableLabel.isHidden = false
                imageView.isHidden = true
            } else if !card!.isDownloadingImage {
                mainImage = UIImage(data: card!.imageData! as Data)
                image = mainImage
            }
        }
    }
    
    private func formatFlipCard() {
        guard layout == "double-faced" else { return }
        
        let flipSpinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        flipSpinner.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: flipSpinner)
        
        fetchFlipSideRequested = true
        var parameters: [String: Any] = [:]
        parameters["name"] = getFlippedName()
        if name != names?[0] {
            parameters["setName"] = set
        }
        store.dispatch(searchForAdditionalCardsActionCreator(url: "https://api.magicthegathering.io/v1/cards", parameters: parameters))
    }
    
    private func formatSideboardButtons() {
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
    
    @objc private func flipButtonPressed() {
        isFlipped ? displayMainSideInfo() : displayFlipSideInfo()
        isFlipped = !isFlipped
        tableView.reloadData()
    }
    
    private func displayFlipSideInfo() {
        tableViewData[0] = flippedCard?.name ?? ""
        tableViewData[1] = ""
        tableViewData[2] = flippedCard?.type ?? ""
        tableViewData[3] = (flippedCard?.power ?? "") + "/" + (flippedCard?.toughness ?? "")
        tableViewData[4] = flippedCard?.setName ?? ""
        tableViewData[5] = flippedCard?.rarity ?? ""
        tableViewData[6] = flippedCard?.text ?? ""
        tableViewData[7] = flippedCard?.flavor ?? ""
        image = flippedImage
    }
    
    private func displayMainSideInfo() {
        tableViewData[0] = name
        tableViewData[1] = manaCost?.withoutBraces ?? ""
        tableViewData[2] = type
        tableViewData[3] = (power ?? "") + "/" + (toughness ?? "")
        tableViewData[4] = set
        tableViewData[5] = rarity
        tableViewData[6] = text ?? ""
        tableViewData[7] = flavor ?? ""
        image = mainImage
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
            present(errorAlert(description: "Unable to access stored card count. Please close the app and try again.", title: "Loading Error"), animated: true) { [unowned self] in
                _ = self.navigationController?.popViewController(animated: true)
            }
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
            present(errorAlert(description: "Unable to access stored card count. Please close the app and try again.", title: "Loading Error"), animated: true) { [unowned self] in
                _ = self.navigationController?.popViewController(animated: true)
            }
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
    
    func newState(state: RootState) {
        if let error = state.coreDataState.coreDataError {
            switch error {
            case .loadingError(let description): present(errorAlert(description: description, title: "Loading Error"), animated: true)
            case .savingError(let description): present(errorAlert(description: description, title: "Saving Error"), animated: true)
            case .otherError(let description): present(errorAlert(description: description, title: nil), animated: true)
            }
            return
        }
        
        // Update card counts.
        getDeckCount()
        getSideboardCount()
        
        let imagesState = state.imagesState
        
        // Main CardResult image download.
        if shouldUseResult {
            if imagesState.mainImageDownloadFailed {
                spinner.stopAnimating()
                imageUnavailableLabel.isHidden = false
                imageView.isHidden = true
            } else if let mainImage = imagesState.mainImage {
                self.mainImage = mainImage
                image = mainImage
            }
        }
        
        // Flip CardResult image download.
        if layout == "double-faced", let flipImage = imagesState.flipImage {
            flippedImage = flipImage
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Flip", style: .plain, target: self, action: #selector(flipButtonPressed))
        }
        
        // Main image download completed from a request made by a prior view controller.
        if !state.coreDataState.isDownloadingImages && !shouldUseResult && spinner.isAnimating {
            mainImage = UIImage(data: card!.imageData! as Data)
            image = mainImage
        }
        
        // Flip side card download complete.
        if fetchFlipSideRequested, let flippedResult = state.searchState.additionalCardResults {
            fetchFlipSideRequested = false
            if flippedResult.isFailure {
                flippedCard = nil
                navigationItem.rightBarButtonItems?.removeAll()
                present(errorAlert(description: "Unable to retrieve flipped card data.", title: "Connection Error"), animated: true)
            } else {
                flippedCard = state.searchState.additionalCardResults?.value?.cards[0]
                if let flippedImageUrlString = flippedCard?.imageUrl, let flippedImageUrl = URL(string: flippedImageUrlString) {
                    store.dispatch(fetchFlipImageActionCreator(url: flippedImageUrl))
                }
            }
        }
    }
    
    
    // MARK: Supporting Functionality
    
    struct ButtonLabels {
        static let makeCommander = "Make Commander"
        static let unmakeCommander = "Remove as Commander"
    }
    
}
