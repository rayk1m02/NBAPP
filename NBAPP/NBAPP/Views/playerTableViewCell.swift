//
//  playerTableViewCell.swift
//  NBAPP
//
//  Created by Raymond Kim on 4/1/24.
//

import Foundation
import UIKit

/*
 This represents the body TableViewCell for the TableView in Team tab
 */
class PlayerTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var jerseyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
