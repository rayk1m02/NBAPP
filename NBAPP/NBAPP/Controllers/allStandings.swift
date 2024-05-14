//
//  allStandings.swift
//  NBAPP
//
//  Created by Raymond Kim on 4/9/24.
//

import UIKit
import Foundation
import SwiftyJSON

/*
 This represents the Standings page for the western and eastern NBA conferences
 */
class AllStandings: UIViewController {
    
    struct Team {
        let rank: String
        let name: String
        let wins: String
        let loss: String
        let pct: String
    }
    
    var westTeams = [Team]()
    var eastTeams = [Team]()
    
    @IBOutlet weak var westTableView: UITableView!
    @IBOutlet weak var eastTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        westTableView.delegate = self
        westTableView.dataSource = self
        westTableView.layer.cornerRadius = 6
        westTableView.layer.masksToBounds = true
        
        eastTableView.delegate = self
        eastTableView.dataSource = self
        eastTableView.layer.cornerRadius = 6
        eastTableView.layer.masksToBounds = true
        
        displayStandings(conference: "west")
        displayStandings(conference: "east")
    }
    
    /*
     Retrieves and displays the standings for all teams in the western and eastern conference
     */
    func displayStandings(conference: String) {
        westTeams.removeAll()
        eastTeams.removeAll()
        // set up api call
        let headers = [
            "X-RapidAPI-Key": "6df4e29f4bmshaa0fe5523a30fc7p1e156djsn09658e569328",
            "X-RapidAPI-Host": "api-nba-v1.p.rapidapi.com"
        ]
        let urlString = "https://api-nba-v1.p.rapidapi.com/standings?league=standard&season=2023&conference=\(conference)"
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
                let teams = json["response"].arrayValue
                for team in teams {
                    let rank = String(team["conference"]["rank"].intValue)
                    let nickname = team["team"]["nickname"].stringValue
                    let wins = String(team["conference"]["win"].intValue)
                    let loss = String(team["conference"]["loss"].intValue)
                    let pct = team["win"]["percentage"].stringValue
                    let temp = Team(rank: rank, name: nickname, wins: wins, loss: loss, pct: pct)
                    if conference == "west" { self.westTeams.append(temp) }
                    else if conference == "east" { self.eastTeams.append(temp) }
                }
                DispatchQueue.main.async {
                    // sort teams by rank
                    if conference == "west" {
                        self.westTeams.sort { Int($0.rank)! < Int($1.rank)! }
                        self.westTableView.reloadData()
                    }
                    else if conference == "east" {
                        self.eastTeams.sort { Int($0.rank)! < Int($1.rank)! }
                        self.eastTableView.reloadData()
                    }
                }
            } catch { print("Error parsing JSON: \(error)") }
        }
        dataTask.resume()
    }
    
}

extension AllStandings: UITableViewDataSource, UITableViewDelegate {
    
    // DataSource
    func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            if section == 0 { return 1 }
            else { return westTeams.count }
        } else if tableView.tag == 1 {
            if section == 0 { return 1 }
            else { return eastTeams.count }
        }
        return 0
    }
    // Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderStandingsCell", for: indexPath) as! HeaderStandingsTableViewCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BodyStandingsCell", for: indexPath) as! BodyStandingsTableViewCell
                let team = westTeams[indexPath.row]
                cell.rankLabel.text = team.rank
                cell.nameLabel.text = team.name
                cell.winsLabel.text = team.wins
                cell.lossLabel.text = team.loss
                cell.pctLabel.text = team.pct
                return cell
            }
        } else if tableView.tag == 1 {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderStandingsCell", for: indexPath) as! HeaderStandingsTableViewCell
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BodyStandingsCell", for: indexPath) as! BodyStandingsTableViewCell
                let team = eastTeams[indexPath.row]
                cell.rankLabel.text = team.rank
                cell.nameLabel.text = team.name
                cell.winsLabel.text = team.wins
                cell.lossLabel.text = team.loss
                cell.pctLabel.text = team.pct
                return cell
            }
        }
        return UITableViewCell()
    }
    
}
