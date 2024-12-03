//
//  ViewController.swift
//  TheChase
//
//

import UIKit

var baseController: ViewController?

class ViewController: UIViewController {
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBOutlet weak var recentGameTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseController = self
        recentGameTableView.delegate = self
        recentGameTableView.dataSource = self
        setHighScore()
    }
}
extension ViewController{
    func setHighScore() {
        let highScore = UserDefaults.standard.integer(forKey: "highScore")
        if highScore == 0 {
            highScoreLabel.text = "High Score not created yet"
        }else{
            highScoreLabel.text = "High Score: \(highScore)"
        }
    }
    func setRecentGame() {
        // Retrieve the dictionary from UserDefaults
        if let recentGame = UserDefaults.standard.dictionary(forKey: "recentGame") {
            // Access each value safely
            if let amount = recentGame["amount"] as? Int, // Use the expected type
               let player = recentGame["player"] as? String {
                print("Amount: \(amount), Player: \(player)")
            }
        } else {
            print("No recent game data found")
        }
    }
}
extension ViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let recentGame = UserDefaults.standard.dictionary(forKey: "recentGame") {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? RecentGameCell else {return UITableViewCell()}
        // Retrieve the dictionary from UserDefaults
        if let recentGame = UserDefaults.standard.dictionary(forKey: "recentGame") {
            // Access each value safely
            if let amount = recentGame["amount"] as? Int, // Use the expected type
               let player = recentGame["player"] as? String {
                cell.scoreLabel.text = "Amount : £\(amount)"
                cell.winnerLabel.text = "Winner : \(player)"
            }
        }
        return cell
    }
    
    
}
class RecentGameCell : UITableViewCell{
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var winnerLabel: UILabel!
    
}
