//
//  headerTableViewCell.swift
//  NBAPP
//
//  Created by Raymond Kim on 4/1/24.
//

import Foundation
import UIKit

/*
 This represents the header TableViewCell for the TableView in Team tab
 Although the UILabels are connected with the View Controller, it is just for formality as the texts have been directly inputted already
 */
class HeaderTableViewCell: UITableViewCell {
    
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
