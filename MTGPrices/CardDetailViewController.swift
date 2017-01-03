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
    
    var mainImage: UIImage?
    
    var flippedCard: CardResult?
    var flippedImage: UIImage?
    var waitingForFlippedResult = false
    var isFlipped = false
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var imageUnavailableLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var deckCountLabel: UILabel!
    @IBOutlet weak var sideboardCountLabel: UILabel!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var sideboardButton: UIButton!
    @IBOutlet weak var decrementSideboardButton: UIButton!
    @IBOutlet weak var makeCommanderButton: UIButton!
    
    
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
    
    @IBAction func flipButtonPressed(_ sender: UIButton) {
        guard !sender.isHidden else { return }
        
        if isFlipped {
            displayMainSideInfo()
            isFlipped = false
        } else {
            displayFlipSideInfo()
            isFlipped = true
        }
    }
    
    @IBAction func addToSideboardButtonPressed(_ sender: UIButton) {
        if shouldUseResult {
            store.dispatch(AddCardResultToSideboard(deck: deck, card: cardResult!))
        } else {
            if !card!.isSideboard {
                store.dispatch(AddMainboardCardToSideboard(deck: deck, mainboardCard: card!))
            } else {
                store.dispatch(IncrementSideboardCardAmount(deck: deck, card: card!))
            }
        }
    }

    @IBAction func removeFromSideboardButtonPressed(_ sender: UIButton) {
        if shouldUseResult {
            store.dispatch(DecrementSideboardCardAmount(deck: deck, cardId: cardResult!.id))
        } else {
            store.dispatch(DecrementSideboardCardAmount(deck: deck, cardId: card!.id))
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        if shouldUseResult {
            store.dispatch(AddCardResultToDeck(deck: deck, card: cardResult!))
        } else {
            if card!.isSideboard {
                store.dispatch(AddSideboardCardToDeck(deck: deck, sideboardCard: card!))
            } else {
                store.dispatch(IncrementMainboardCardAmount(deck: deck, card: card!))
            }
        }
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        if shouldUseResult {
            store.dispatch(DecrementMainboardCardAmount(deck: deck, cardId: cardResult!.id))
        } else {
            store.dispatch(DecrementMainboardCardAmount(deck: deck, cardId: card!.id))
        }
    }
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            imageView.image = mainImage
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
        flipButton.isHidden = true
        let hasFlipSide = shouldUseResult ? cardResult!.layout == "double-faced" : card!.layout == "double-faced"
        if hasFlipSide {
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
            sideboardCountLabel.isHidden = true
        }
        
        if deck.format != "Commander" {
            makeCommanderButton.isHidden = true
        } else if !shouldUseResult && card!.isCommander {
            makeCommanderButton.setTitle("Remove as Commander", for: .normal)
        } else {
            makeCommanderButton.setTitle("Make Commander", for: .normal)
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
        if shouldUseResult {
            store.dispatch(UpdateCardReference(deck: deck, cardId: cardResult!.id))
        } else {
            store.dispatch(UpdateCardReference(deck: deck, cardId: card!.id))
        }
        store.unsubscribe(self)
    }
    
    // MARK: - Methods
    
    private func mainImageDownloadComplete() {
        if !shouldUseResult && spinner.isAnimating {
            mainImage = UIImage(data: card!.imageData! as Data)
            imageView.image = mainImage
            spinner.stopAnimating()
        }
    }
    
    private func displayFlipSideInfo() {
        cardNameLabel.text = flippedCard!.name
        costLabel.text = "Cost: None"
        typeLabel.text = "Types: \(flippedCard!.type!)"
        textLabel.text = flippedCard!.text?.withoutBraces
        imageView.image = flippedImage
    }
    
    private func displayMainSideInfo() {
        let cardName = shouldUseResult ? cardResult!.name : card!.name
        let cost = shouldUseResult ? cardResult!.manaCost : card!.manaCost
        let type = shouldUseResult ? cardResult!.type : card!.type
        let text = shouldUseResult ? cardResult!.text : card!.text
        
        cardNameLabel.text = cardName
        costLabel.text = "Cost: \(cost?.withoutBraces ?? "None")"
        typeLabel.text = "Types: \(type!)"
        textLabel.text = text?.withoutBraces
        imageView.image = mainImage
    }
    
    private func fetchMainImage(from urlString: String) {
        let cardUrl = URL(string: urlString)!
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            if let data = try? Data(contentsOf: cardUrl) {
                DispatchQueue.main.async {
                    let mainImage = UIImage(data: data)
                    self?.spinner.stopAnimating()
                    self?.imageView.image = mainImage
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
        
        DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
            if let data = try? Data(contentsOf: cardUrl) {
                DispatchQueue.main.async {
                    self.flippedImage = UIImage(data: data)
                    self.flipButton.isHidden = false
                }
            }
        }
    }
    
    private func getDeckCount() {
        let request = Card.createFetchRequest()
        let cardId = shouldUseResult ? cardResult!.id : card!.id
        request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == false", deck.id, cardId!)
        if let cards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
            if !cards.isEmpty {
                deckCountLabel.text = "Deck Count: \(cards[0].amount)"
            } else {
                deckCountLabel.text = "Deck Count: 0"
            }
        } else {
            print("error fetching card count in deck")
        }
    }
    
    private func getSideboardCount() {
        let request = Card.createFetchRequest()
        let cardId = shouldUseResult ? cardResult!.id : card!.id
        request.predicate = NSPredicate(format: "deck.id == %@ AND id == %@ AND isSideboard == true", deck.id, cardId!)
        if let cards = try? appDelegate.persistentContainer.viewContext.fetch(request) {
            if !cards.isEmpty {
                sideboardCountLabel.text = "Sideboard Count: \(cards[0].amount)"
            } else {
                sideboardCountLabel.text = "Sideboard Count: 0"
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
