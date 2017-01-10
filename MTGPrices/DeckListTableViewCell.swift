//
//  DeckListTableViewCell.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/26/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import UIKit

class DeckListTableViewCell: UITableViewCell {

    @IBAction func editButtonTapped(_ sender: UIButton) {
//        sender.setImage(UIImage(named: "editSelected.png"), for: .normal)
        buttonDelegate?.buttonTapped(deckId: deckId)
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    var deckId: String!
    var buttonDelegate: ButtonDelegate?

}

protocol ButtonDelegate {
    func buttonTapped(deckId id: String)
}
