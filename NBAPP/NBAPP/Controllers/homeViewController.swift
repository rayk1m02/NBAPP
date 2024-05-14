//
//  homeViewController.swift
//  NBAPP
//
//  Created by Raymond Kim on 3/30/24.
//

import UIKit
import Foundation
import SwiftyJSON
import Kingfisher

/*
 This represents the Main page where the user selects a team
 */
class HomeViewController: UIViewController {
    
    var nbaTeams = [
        "Atlanta Hawks",
        "Boston Celtics",
        "Brooklyn Nets",
        "Charlotte Hornets",
        "Chicago Bulls",
        "Cleveland Cavaliers",
        "Dallas Mavericks",
        "Denver Nuggets",
        "Detroit Pistons",
        "Golden State Warriors",
        "Houston Rockets",
        "Indiana Pacers",
        "LA Clippers",
        "Los Angeles Lakers",
        "Memphis Grizzlies",
        "Miami Heat",
        "Milwaukee Bucks",
        "Minnesota Timberwolves",
        "New Orleans Pelicans",
        "New York Knicks",
        "Oklahoma City Thunder",
        "Orlando Magic",
        "Philadelphia 76ers",
        "Phoenix Suns",
        "Portland Trail Blazers",
        "Sacramento Kings",
        "San Antonio Spurs",
        "Toronto Raptors",
        "Utah Jazz",
        "Washington Wizards"
    ]
    
    struct Player {
        let firstName: String
        let lastNameInitial: String
        let position: String
        let jersey: Int
    }
    
    var players = [Player]()
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var teamLogo: UIImageView!
    @IBOutlet weak var westLabel: UILabel!
    @IBOutlet weak var eastLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        westLabel.isHidden = true
        westLabel.layer.cornerRadius = 6
        westLabel.layer.masksToBounds = true
        
        eastLabel.isHidden = true
        eastLabel.layer.cornerRadius = 6
        eastLabel.layer.masksToBounds = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 6
        tableView.layer.masksToBounds = true
    }
    
    /*
     Hides the back button
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.hidesBackButton = true
    }
    
    /*
     Displays the team logo, conference, and makes a call to fetchTeamRoster()
     */
    func fetchTeamData(name: String) {
        // set up api call
        let headers = [
            "X-RapidAPI-Key": "6df4e29f4bmshaa0fe5523a30fc7p1e156djsn09658e569328",
            "X-RapidAPI-Host": "api-nba-v1.p.rapidapi.com"
        ]
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
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
                if let logoURL = json["response"][0]["logo"].string,
                    let id = json["response"][0]["id"].int,
                    let conference = json["response"][0]["leagues"]["standard"]["conference"].string {
                    DispatchQueue.main.async {
                        self.westLabel.isHidden = true
                        self.eastLabel.isHidden = true
                        self.teamLogo.kf.indicatorType = .activity
                        self.teamLogo.kf.setImage(with: URL(string: logoURL), placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)
                        if conference == "West" {
                            self.westLabel.text = conference
                            self.westLabel.isHidden = false
                        } else if conference == "East" {
                            self.eastLabel.text = conference
                            self.eastLabel.isHidden = false
                        }
                    }
                    print(name, conference, id)
                    self.fetchTeamRoster(team: String(id), season: 2023)
                    // save the team name and id so we can access it in Games tab
                    SharedDataModel.shared.teamName = name
                    SharedDataModel.shared.teamId = String(id)
                }
            } catch { print("Error parsing JSON: \(error)") }
        }
        dataTask.resume()
    }
    
    /*
     Fetches and displays the teams roster (only active players)
     Player name, position, and jersey number
     */
    func fetchTeamRoster(team: String, season: Int) {
        // set up api call
        let headers = [
            "X-RapidAPI-Key": "6df4e29f4bmshaa0fe5523a30fc7p1e156djsn09658e569328",
            "X-RapidAPI-Host": "api-nba-v1.p.rapidapi.com"
        ]
        let urlString = "https://api-nba-v1.p.rapidapi.com/players?team=\(team)&season=\(season)"
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
                let players = json["response"].arrayValue
                self.players.removeAll()
                for player in players {
                    let firstName = player["firstname"].stringValue
                    let lastNameInitial = String(player["lastname"].stringValue.first!)
                    let position = player["leagues"]["standard"]["pos"].stringValue
                    let jersey = player["leagues"]["standard"]["jersey"].intValue
                    let active = player["leagues"]["standard"]["active"].boolValue
                    if active {
                        let player = Player(firstName: firstName, lastNameInitial: lastNameInitial, position: position, jersey: jersey)
                        self.players.append(player)
                    }
                }
                DispatchQueue.main.async { self.tableView.reloadData() }
            } catch { print("Error parsing JSON: \(error)") }
        }
        dataTask.resume()
    }
    
}

extension HomeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // White font color
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: nbaTeams[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    // DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return nbaTeams.count }
    // Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { return nbaTeams[row] }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let name = nbaTeams[row]
        fetchTeamData(name: name)
    }
    
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    // DataSource
    func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        else { return players.count }
    }
    // Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! HeaderTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as! PlayerTableViewCell
            let player = players[indexPath.row]
            cell.nameLabel.text = "\(player.firstName) \(player.lastNameInitial)."
            cell.positionLabel.text = player.position
            cell.jerseyLabel.text = "\(player.jersey)"
            return cell
        }
    }
    
}
