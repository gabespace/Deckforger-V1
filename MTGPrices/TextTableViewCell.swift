//
//  TextTableViewCell
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/2/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
