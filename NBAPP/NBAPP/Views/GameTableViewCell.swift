//
//  GameTableViewCell.swift
//  NBAPP
//
//  Created by Raymond Kim on 4/11/24.
//

import UIKit
import SwiftyJSON
import Kingfisher

/*
 This represents the body TableViewCell for the TableView in Games tab
 */
class GameTableViewCell: UITableViewCell {

    @IBOutlet weak var homeImageView: UIImageView!
    @IBOutlet weak var visitorImageView: UIImageView!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var visitorLabel: UILabel!
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var visitorScoreLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /*
     Displays team logo within the cell
     sideName: for either home teams ImageView or visitor teams ImageView
     */
    func displayLogo(teamName: String, sideName: String) {
        // set up api call
        let headers = [
            "X-RapidAPI-Key": "6df4e29f4bmshaa0fe5523a30fc7p1e156djsn09658e569328",
            "X-RapidAPI-Host": "api-nba-v1.p.rapidapi.com"
        ]
        let encodedName = teamName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = "https://api-nba-v1.p.rapidapi.com/teams?name=\(encodedName)"
        guard let url = URL(string: urlString) else { print("Invalid URL"); return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            // safety checks
            if let error = error { print("Error: \(error)"); return }
            guard let httpResponse = response as? HTTPURLResponse else { print("Invalid response"); return }
            guard httpResponse.statusCode == 200 else { print("HTTP error: \(httpResponse.statusCode)"); return }
            guard let data = data else { print("No data received"); return }
            // retrieve and display data
            do {
                let json = try JSON(data: data)
                if let logoURL = json["response"][0]["logo"].string {
                    DispatchQueue.main.async {
                        if sideName == "homeImageView" {
                            self.homeImageView.kf.indicatorType = .activity
                            self.homeImageView.kf.setImage(with: URL(string: logoURL), placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)
                        } else { // "visitorImageView"
                            self.visitorImageView.kf.indicatorType = .activity
                            self.visitorImageView.kf.setImage(with: URL(string: logoURL), placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)
                        }
                    }
                }
            } catch { print("Error parsing JSON: \(error)") }
        }
        dataTask.resume()
    }
    
}
