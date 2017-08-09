//
//  PenaltiesTableViewController.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/6/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class PenaltiesTableViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate {
    
    var event: Event?
    var penalties: [Penalty] = []
    var filteredPenalties: [Penalty] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var penaltiesTableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var penaltiesSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        penaltiesTableView.setContentOffset(CGPoint(x:0,y:searchController.searchBar.frame.size.height), animated: false)
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search by Bib Number..."
        searchController.searchBar.keyboardType = .numberPad
        penaltiesTableView.tableHeaderView = searchController.searchBar
        
        penaltiesSegmentedControl.tintColor = appDelegate.darkBlueColor
        sortSegmentedControl.tintColor = appDelegate.darkBlueColor

    }
    
    override func viewWillAppear(_ animated: Bool) {
        penaltiesTableView.isHidden = true
        aiv.isHidden = false
        aiv.startAnimating()
        
        if let event = event {
            navItem.title = event.name
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getPenalties(eventID: (event?.uid)!)
    }
    
    func getPenalties(eventID: String) {
        aiv.isHidden = false
        aiv.startAnimating()
        penaltiesTableView.isHidden = true
        if GlobalFunctions.shared.hasConnectivity() {
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
        } else {
            self.displayAlert(title: "No Internet Connectivity", message: "Establish an Internet Connection and try again.")
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
        
        sortPenalties()
        penaltiesTableView.reloadData()
        
    }
    
    func sortPenalties() {
        if sortSegmentedControl.selectedSegmentIndex == 0 {
            penalties.sort { $0.timeStamp < $1.timeStamp }
        } else {
            penalties.sort { Int($0.bibNumber)! < Int($1.bibNumber)! }
        }
    }
    
    @IBAction func filterCriteronChanged(_ sender: Any) {
        getPenalties(eventID: (event?.uid)!)
    }
    
    @IBAction func sortCriterionChanged(_ sender: Any) {
        sortPenalties()
        penaltiesTableView.reloadData()
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
    
    func confirmCheckIn(bibNumber: String) {
        let alert = UIAlertController(title: "Check in Bib Number \(bibNumber)?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
            self.getPenalties(eventID: (self.event?.uid)!)
        })
        self.present(alert, animated: false, completion: nil)
    }
    
    func confirmUnCheckIn(bibNumber: String) {
        let alert = UIAlertController(title: "Undo check in for Bib Number \(bibNumber)?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
            self.getPenalties(eventID: (self.event?.uid)!)
        })
        self.present(alert, animated: false, completion: nil)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredPenalties = penalties.filter { penalty in
            return penalty.bibNumber.contains(searchText)
        }
        penaltiesTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        penaltiesSegmentedControl.isEnabled = false
        sortSegmentedControl.isEnabled = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        penaltiesSegmentedControl.isEnabled = true
        sortSegmentedControl.isEnabled = true
    }
    
    @IBAction func editEventButtonPressed(_ sender: Any) {
        if event?.admin == Auth.auth().currentUser?.uid {
            let createEventVC = storyboard?.instantiateViewController(withIdentifier: "CreateEventViewController") as! CreateEventViewController
            createEventVC.event = event
            self.navigationController?.pushViewController(createEventVC, animated: true)
        } else {
            displayAlert(title: "Access Denied", message: "Only the admin of this event is allowed to edit it.")
        }
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
        if searchController.isActive {
            return filteredPenalties.count
        }
        return penalties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "penaltyCell") as! PenaltyCell
        if searchController.isActive {
            cell.setUpCell(penalty: filteredPenalties[indexPath.row], vc: self, eventID: (event?.uid)!)
        } else {
            cell.setUpCell(penalty: penalties[indexPath.row], vc: self, eventID: (event?.uid)!)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var penalty = penalties[indexPath.row]
        if searchController.isActive {
            penalty = filteredPenalties[indexPath.row]
        }
        
        var checkedIn = "No"
        if penalty.checkedIn {
            checkedIn = "Yes"
        }
        
        var penaltyMessage = ""
        if penalty.penalty == "Drafting" {
            penaltyMessage = "\(penalty.penalty) (\(penalty.bikeLengths) lengths, \(penalty.seconds) s)"
        } else {
            penaltyMessage = penalty.penalty
        }
        
        let formattedTimeStamp = GlobalFunctions.shared.formattedTimestamp(ts: penalty.timeStamp)
        
        let message = "\n Checked in: \(checkedIn) \n Bib Number: \(penalty.bibNumber) \n Gender: \(penalty.gender) \n Bike Type: \(penalty.bikeType) \n Bike Color: \(penalty.bikeColor) \n Helmet Color: \(penalty.helmetColor) \n Top Color: \(penalty.topColor) \n Pant Color: \(penalty.pantColor) \n Penalty: \(penaltyMessage) \n Approximate Mile: \(penalty.approximateMile) \n\n Submitted by \(penalty.submittedBy) at \(formattedTimeStamp)."
        
        let penaltyDetails = UIAlertController(title: "Penalty Details", message: message, preferredStyle: .alert)
        
        let closeAction = UIAlertAction(title: "Close", style: .cancel) { (_) in }
        let editAction = UIAlertAction(title: "Edit", style: .default) { (_) in
            let logPenaltyVC = self.storyboard?.instantiateViewController(withIdentifier: "LogPenaltyViewController") as! LogPenaltyViewController
            logPenaltyVC.eventID = self.event?.uid
            logPenaltyVC.penalty = penalty
            self.navigationController?.pushViewController(logPenaltyVC, animated: true)
        }
        
        penaltyDetails.addAction(editAction)
        penaltyDetails.addAction(closeAction)
        
        self.present(penaltyDetails, animated: false, completion: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var penalty = penalties[indexPath.row]
            if searchController.isActive {
                penalty = filteredPenalties[indexPath.row]
            }
            let alert = UIAlertController(title: "Delete Penalty", message: "This can't be undone. Are you sure you want to continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
                if GlobalFunctions.shared.hasConnectivity() {
                    FirebaseClient.shared.deletePenalty(eventID: (self.event?.uid)!, penaltyID: penalty.uid) { (success) -> () in
                        if let success = success {
                            if success {
                                self.displayAlert(title: "Success", message: "The penalty was successfully deleted.")
                                self.getPenalties(eventID: (self.event?.uid)!)
                            } else {
                                self.displayAlert(title: "Error", message: "The penalty couldn't be deleted.")
                            }
                        } else {
                            self.displayAlert(title: "Error", message: "The penalty couldn't be deleted.")
                        }
                    }
                } else {
                    self.displayAlert(title: "No Internet Connectivity", message: "Establish an Internet Connection and try again.")
                }
            })
            self.present(alert, animated: false, completion: nil)
        }
    }
    
}

extension PenaltiesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
