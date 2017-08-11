//
//  PenaltiesTableViewController.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/6/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class PenaltiesTableViewController: UIViewController, UISearchBarDelegate, UISearchControllerDelegate {
    
    var event: Event?
    var penalties: [Penalty] = []
    var filteredPenalties: [Penalty] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    var checkedInCount = 0
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var penaltiesTableView: UITableView!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var penaltiesSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var emailCSVButton: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        penaltiesTableView.setContentOffset(CGPoint(x:0,y:searchController.searchBar.frame.size.height), animated: false)
        toolbar.isTranslucent = false
        
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
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(PenaltiesTableViewController.getPenalties), for: .valueChanged)
        
        penaltiesTableView.refreshControl = self.refreshControl
        
        emailCSVButton.tintColor = appDelegate.darkBlueColor
    
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
        getPenalties()
    }
    
    func getPenalties() {
        if GlobalFunctions.shared.hasConnectivity() {
            FirebaseClient.shared.getPenalties(eventID: (self.event?.uid)!) { (penalties, checkedInCount, error) -> () in
                self.aiv.isHidden = true
                self.aiv.stopAnimating()
                if error == "No Penalties Yet" {
                    self.penaltiesTableView.isHidden = false
                    self.penaltiesTableView.reloadData()
                    self.refreshControl.endRefreshing()
                    return
                }
                if let penalties = penalties, let checkedInCount = checkedInCount {
                    self.checkedInCount = checkedInCount
                    self.penalties = penalties
                    self.filterThenSortPenalties()
                    self.penaltiesTableView.isHidden = false
                    self.refreshControl.attributedTitle = NSAttributedString(string: "Last Updated: \(self.lastUpdatedTime())")
                    self.refreshControl.endRefreshing()
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
    
    func lastUpdatedTime() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd HH:mm:ss:SSS"
        let dateString = dateFormatter.string(from: date)
        return GlobalFunctions.shared.formattedTimestamp(ts: dateString, includeDate: true)
    }
    
    func sortPenalties() {
        if sortSegmentedControl.selectedSegmentIndex == 0 {
            penalties.sort { $0.timeStamp < $1.timeStamp }
        } else {
            penalties.sort { Int($0.bibNumber)! < Int($1.bibNumber)! }
        }
    }
    
    @IBAction func filterCriteronChanged(_ sender: Any) {
        getPenalties()
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
            self.getPenalties()
        })
        self.present(alert, animated: false, completion: nil)
    }
    
    func confirmUnCheckIn(bibNumber: String) {
        let alert = UIAlertController(title: "Undo check in for Bib Number \(bibNumber)?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
            self.getPenalties()
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

    @IBAction func emailCSVButtonPressed(_ sender: Any) {
        if penalties.count > 0 {
            emailCSV()
        } else {
            displayAlert(title: "No Penalties", message: "A CSV cannot be created with 0 penalties.")
        }
    }
    
    func emailCSV() {
        if let event = event {
            let name = event.name
            let date = formatDate(from: event.date)
            let segment = penaltiesSegmentedControl.titleForSegment(at: penaltiesSegmentedControl.selectedSegmentIndex)!
            let fileName = "\(date)_\(name)_\(segment) Penalties.csv"
            print(fileName)
            let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            let header = "Checked In,Bib Number,Penalty,Bike Lengths,Seconds,Approximate Mile,Gender,Bike Type,Bike Color,Helmet Color,Top Color,Pant Color,Submitted By,Time Submitted,Notes"

            var dataString = header
            for p in penalties {
                var checkedInString = "No"
                if p.checkedIn {
                    checkedInString = "Yes"
                }
                dataString = "\(dataString)\n\(checkedInString),\(p.bibNumber),\(p.penalty),\(p.bikeLengths),\(p.seconds),\(p.approximateMile),\(p.gender),\(p.bikeType),\(p.bikeColor),\(p.helmetColor),\(p.topColor),\(p.pantColor),\(p.submittedBy),\(p.timeStamp),\(p.notes)"
            }
            do {
                try dataString.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("Failed to create file")
                print("\(error)")
            }
            
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            
            mailComposerVC.setSubject(fileName)
            mailComposerVC.setToRecipients([(Auth.auth().currentUser?.email)!])
           
            do {
                let data = try Data(contentsOf: path!)
                mailComposerVC.addAttachmentData(data, mimeType: "text/csv", fileName: fileName)
                present(mailComposerVC, animated: false, completion: nil)
            } catch {
                print(error.localizedDescription)
            }
        
        }
    }
    
    func formatDate(from date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        let dateDate = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: dateDate!)
    }
    
}

extension PenaltiesTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive {
            return nil
        }
        if penaltiesSegmentedControl.selectedSegmentIndex == 0 {
            if penalties.count > 1 {
                return "\(penalties.count) Penalties (\(checkedInCount)/\(penalties.count) Checked In)"
            } else if penalties.count == 1 {
                return "1 Penalty (\(checkedInCount)/\(1) Checked In)"
            } else {
                return "0 Penalties"
            }
        }
        if penaltiesSegmentedControl.selectedSegmentIndex == 1 {
            if penalties.count != 1 {
                return "\(penalties.count) Penalties Checked In"
            } else {
                return "1 Penalty Checked In"
            }
        }
        if penaltiesSegmentedControl.selectedSegmentIndex == 2 {
            if penalties.count != 1 {
                return "\(penalties.count) Penalties Not Checked In"
            } else {
                return "1 Penalty Not Checked In"
            }
        }
        return nil
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
            searchController.isActive = false
            searchController.searchBar.text = ""
            searchController.dismiss(animated: false, completion: nil)
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
        
        let formattedTimeStamp = GlobalFunctions.shared.formattedTimestamp(ts: penalty.timeStamp, includeDate: false)
        
        let message = "\n Checked in: \(checkedIn) \n Bib Number: \(penalty.bibNumber) \n Penalty: \(penaltyMessage) \n Approximate Mile: \(penalty.approximateMile) \n Gender: \(penalty.gender) \n Bike Type: \(penalty.bikeType) \n Bike Color: \(penalty.bikeColor) \n Helmet Color: \(penalty.helmetColor) \n Top Color: \(penalty.topColor) \n Pant Color: \(penalty.pantColor) \n\n Submitted by \(penalty.submittedBy) at \(formattedTimeStamp)."
        
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
                                self.getPenalties()
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

extension PenaltiesTableViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        if result == .failed {
            displayAlert(title: "Email Not Sent", message: "The email failed to send, please try again.")
        } else if result == .sent {
            displayAlert(title: "Email Sent", message: "The email was successfully sent.")
        }
    }
    
}

extension PenaltiesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
