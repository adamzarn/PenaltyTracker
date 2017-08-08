//
//  PenaltiesTableViewController.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/6/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit

class PenaltiesTableViewController: UIViewController {
    
    var event: Event?
    var penalties: [Penalty] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var penaltiesTableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var penaltiesSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let event = event {
            navItem.title = event.name
        }
        
        penaltiesSegmentedControl.tintColor = appDelegate.darkBlueColor
        sortSegmentedControl.tintColor = appDelegate.darkBlueColor

    }
    
    override func viewWillAppear(_ animated: Bool) {
        penaltiesTableView.isHidden = true
        aiv.isHidden = false
        aiv.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getPenalties(eventID: (event?.uid)!)
    }
    
    func getPenalties(eventID: String) {
        aiv.isHidden = false
        aiv.startAnimating()
        penaltiesTableView.isHidden = true
        FirebaseClient.shared.getPenalties(eventID: eventID) { (penalties, error) -> () in
            self.aiv.isHidden = true
            self.aiv.stopAnimating()
            if error == "No Penalties Yet" {
                self.penaltiesTableView.isHidden = false
                self.penaltiesTableView.reloadData()
                return
            }
            if let penalties = penalties {
                self.penalties = penalties
                self.filterThenSortPenalties()
                self.penaltiesTableView.isHidden = false
            } else {
                self.displayAlert(title: "Error", message: "Could not load penalties. Please try again.")
            }
        }
    }
    
    func filterThenSortPenalties() {
        
        if penaltiesSegmentedControl.selectedSegmentIndex == 1 {
            penalties = penalties.filter { penalty in
                return(penalty.checkedIn)
            }
        } else if penaltiesSegmentedControl.selectedSegmentIndex == 2 {
            penalties = penalties.filter { penalty in
                return(!penalty.checkedIn)
            }
        }
        
        if sortSegmentedControl.selectedSegmentIndex == 0 {
            penalties.sort { $0.timeStamp < $1.timeStamp }
        } else {
            penalties.sort { Int($0.bibNumber)! < Int($1.bibNumber)! }
        }

        penaltiesTableView.reloadData()
        
    }
    
    @IBAction func filterCriteronChanged(_ sender: Any) {
        getPenalties(eventID: (event?.uid)!)
    }
    
    @IBAction func sortCriterionChanged(_ sender: Any) {
        getPenalties(eventID: (event?.uid)!)
    }
    
    @IBAction func logPenaltyButtonPressed(_ sender: Any) {
        
        let logPenaltyVC = self.storyboard?.instantiateViewController(withIdentifier: "LogPenaltyViewController") as! LogPenaltyViewController
        logPenaltyVC.eventID = self.event?.uid
        self.navigationController?.pushViewController(logPenaltyVC, animated: true)
        
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }

}

extension PenaltiesTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Penalties"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return penalties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "penaltyCell") as! PenaltyCell
        cell.setUpCell(penalty: penalties[indexPath.row], vc: self, eventID: (event?.uid)!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    
}
