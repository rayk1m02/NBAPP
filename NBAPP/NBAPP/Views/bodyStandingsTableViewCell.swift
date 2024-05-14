//
//  bodyStandingsTableViewCell.swift
//  NBAPP
//
//  Created by Raymond Kim on 4/25/24.
//

import Foundation
import UIKit

/*
 This represents the body TableViewCell for both TableViews in Standings tab
 */
class BodyStandingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var winsLabel: UILabel!
    @IBOutlet weak var lossLabel: UILabel!
    @IBOutlet weak var pctLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
