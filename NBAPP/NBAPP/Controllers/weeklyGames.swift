//
//  weeklyGames.swift
//  NBAPP
//
//  Created by Raymond Kim on 4/9/24.
//

import UIKit
import Foundation
import SwiftyJSON
import Kingfisher

/*
 This represents the Games page where the selected teams weekly games are displayed
 */
class WeeklyGames: UIViewController {
    
    var teamName = ""
    var teamId = ""
    
    struct Game {
        let date: String
        // team's fullname for data retrieval
        let homeName: String
        let visitorName: String
        // team's nickname for display
        let homeNameDisplayed: String
        let visitorNameDisplayed: String
        let homeScore: String
        let visitorScore: String
        let timeStamp: String
    }
    
    var games = [Game]()
    
    @IBOutlet weak var teamLogo: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 6
        tableView.layer.masksToBounds = true
        tableView.register(UINib(nibName: "GameTableViewCell", bundle: nil), forCellReuseIdentifier: "GamesCell")
        tableView.rowHeight = 80
    }
    
    /*
     This allows changes to be reflected when user selects a different team in Team tab.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let teamName = SharedDataModel.shared.teamName, let teamId = SharedDataModel.shared.teamId {
            self.teamName = teamName
            self.teamId = teamId
            displayLogo(name: teamName)
            displayGames(id: teamId)
        } else { print("Did not retrieve team name") }
    }
    
    /*
     Retrieves and displays data for games of the week, including team names, scores, and time/date
     If a game has taken place, the score is displayed
     If a game is yet to take place, the time is displayed
     Home team is displayed on the left, visiting team on the right
     */
    func displayGames(id: String) {
        games.removeAll()
        // set up api call
        let group = DispatchGroup()
        let headers = [
            "X-RapidAPI-Key": "6df4e29f4bmshaa0fe5523a30fc7p1e156djsn09658e569328",
            "X-RapidAPI-Host": "api-nba-v1.p.rapidapi.com"
        ]
        let urlString = "https://api-nba-v1.p.rapidapi.com/games?date=%@&season=2023"
        // get the start of the current week (Monday) through DateFormatter() and Calendar
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // current date
        let todayFormatted = dateFormatter.string(from: Date())
        let calendar = Calendar.current
        var startOfWeekComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dateFormatter.date(from: todayFormatted)!)
        // 2 represents Monday
        startOfWeekComponents.weekday = 2
        guard let startOfWeek = calendar.date(from: startOfWeekComponents) else { fatalError("Failed to calculate the start of the week.") }
        let daysOfTheWeek = ["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"]
        // iterate from Monday to Sunday
        for i in 0..<7 {
            group.enter()
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let dateString = dateFormatter.string(from: date) // 2024-04-22
                let formattedUrlString = String(format: urlString, dateString)
                let dayOfTheWeek = daysOfTheWeek[i]
                guard let url = URL(string: formattedUrlString) else { print("Invalid URL"); return }
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.allHTTPHeaderFields = headers
                let session = URLSession.shared
                let dataTask = session.dataTask(with: request) { (data, response, error) in
                    // safety checks
                    defer { group.leave() }
                    if let error = error { print("Error: \(error)"); return }
                    guard let httpResponse = response as? HTTPURLResponse else { print("Invalid response"); return }
                    guard httpResponse.statusCode == 200 else { print("HTTP error: \(httpResponse.statusCode)"); return }
                    guard let data = data else { print("No data received"); return }
                    // retrieve and display data
                    do {
                        let json = try JSON(data: data)
                        let games = json["response"].arrayValue
                        if games.count > 0 {
                            for j in 0..<games.count {
                                if games[j]["teams"]["home"]["id"].stringValue == id ||
                                    games[j]["teams"]["visitors"]["id"].stringValue == id {
                                    let gameResponse = games[j]
                                    let homeName = gameResponse["teams"]["home"]["name"].stringValue
                                    let visitorName = gameResponse["teams"]["visitors"]["name"].stringValue
                                    let homeNameDisplayed = gameResponse["teams"]["home"]["nickname"].stringValue
                                    let visitorNameDisplayed = gameResponse["teams"]["visitors"]["nickname"].stringValue
                                    let jsonDate = gameResponse["date"]["start"].stringValue // "2024-04-10T23:30:00.000Z"
                                    let components = dateString.split(separator: "-")
                                    guard components.count >= 3, let month = Int(components[1]), let day = Int(components[2]) else { fatalError("Invalid date string format.") }
                                    // get the hour, minute, and AM/PM for the current game
                                    let gameTime = self.getGameTime(dateString: jsonDate)
                                    let hour = gameTime.0
                                    let minute = gameTime.1
                                    var timeStamp = gameTime.2
                                    let date = "\(dayOfTheWeek), \(month)/\(day)" // "Mon, 4/22"
                                    var homeScore = "0"
                                    var visitorScore = "0"
                                    guard let todayDate = dateFormatter.date(from: todayFormatted) else { fatalError("Failed to convert todayFormatted to Date.") }
                                    guard let gameDate = dateFormatter.date(from: dateString) else { fatalError("Failed to convert dateString to Date.") }
                                    // if the gameDate has past, the scores are displayed
                                    // if the gameDate is in the future, the time of the game is displayed
                                    if gameDate < todayDate {
                                        homeScore = String(gameResponse["scores"]["home"]["points"].intValue)
                                        visitorScore = String(gameResponse["scores"]["visitors"]["points"].intValue)
                                        timeStamp = ""
                                    } else {
                                        homeScore = hour
                                        visitorScore = minute
                                    }
                                    let game = Game(date: date, homeName: homeName, visitorName: visitorName, homeNameDisplayed: homeNameDisplayed, visitorNameDisplayed: visitorNameDisplayed, homeScore: homeScore, visitorScore: visitorScore, timeStamp: timeStamp)
                                    self.games.append(game)
                                }
                            }
                        }
                    } catch { print("Error parsing JSON: \(error)") }
                }
                dataTask.resume()
            }
        }
        group.notify(queue: .main) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, MM/dd"
            // sort games by date
            self.games.sort {
                if let date1 = dateFormatter.date(from: $0.date), 
                    let date2 = dateFormatter.date(from: $1.date) {
                    return date1 < date2
                } 
                return false
            }
            self.tableView.reloadData()
        }
    }
    
    /*
     Displays the team logo at the top of the page
     */
    func displayLogo(name: String) {
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
                if let logoURL = json["response"][0]["logo"].string {
                    DispatchQueue.main.async {
                        self.teamLogo.kf.indicatorType = .activity
                        self.teamLogo.kf.setImage(with: URL(string: logoURL), placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil)
                    }
                }
            } catch { print("Error parsing JSON: \(error)") }
        }
        dataTask.resume()
    }
    
    /*
     Returns the (hour, minute, AM/PM) -> (09, 30, PM)
     Converts to Date object
     */
    func getGameTime(dateString: String) -> (String, String, String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = dateFormatter.date(from: dateString) else { fatalError("Invalid date string format.") }
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let amPm = hour < 12 ? "AM" : "PM"
        let hour12 = hour > 12 ? hour - 12 : hour // 12-hr format
        let hourString = String(format: "%02d", hour12)
        let minuteString = String(format: "%02d", minute)
        return (hourString, minuteString, amPm)
    }
    
}

extension WeeklyGames: UITableViewDataSource, UITableViewDelegate {
    
    // DataSource
    func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        else { return games.count }
    }
    // Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderGamesCell", for: indexPath) as! HeaderGamesTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GamesCell", for: indexPath) as! GameTableViewCell
            let game = games[indexPath.row]
            cell.displayLogo(teamName: game.homeName, sideName: "homeImageView")
            cell.displayLogo(teamName: game.visitorName, sideName: "visitorImageView")
            cell.dateLabel.text = game.date
            cell.homeLabel.text = game.homeNameDisplayed
            cell.visitorLabel.text = game.visitorNameDisplayed
            cell.homeScoreLabel.text = game.homeScore
            cell.visitorScoreLabel.text = game.visitorScore
            cell.timeStampLabel.text = game.timeStamp
            return cell
        }
    }
    
}
