//
//  EventsViewController.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/4/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class EventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UISearchBarDelegate, UISearchControllerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var events: [Event] = []
    var filteredEvents: [Event] = []

    @IBOutlet weak var aiv: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    @IBOutlet weak var myTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.setContentOffset(CGPoint(x:0,y:searchController.searchBar.frame.size.height), animated: false)
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = false
        searchController.hidesNavigationBarDuringPresentation = false
        myTableView.tableHeaderView = searchController.searchBar
    
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func loadEvents() {
        
        if GlobalFunctions.shared.hasConnectivity() {
            
            FirebaseClient.shared.getEvents() { (events, error) -> () in
                if let events = events {
                    self.events = events
                } else {
                    print(error!)
                }
                self.myTableView.reloadData()
                self.myTableView.isHidden = false
            }
        } else {
            self.displayAlert(title: "No Internet Connectivity", message: "Establish an internet connection and try again.")
        }
    }
    
    func displayAlert(title: String, message: String) {
        aiv.isHidden = true
        aiv.stopAnimating()
        loadingLabel.isHidden = true
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        myTableView.isHidden = true
        aiv.isHidden = false
        aiv.startAnimating()
        
        loadEvents()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCell
        cell.setUpCell(event: events[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let penaltiesVC = storyboard?.instantiateViewController(withIdentifier: "PenaltiesTableViewController") as! PenaltiesTableViewController
        penaltiesVC.event = events[indexPath.row]
        self.navigationController?.pushViewController(penaltiesVC, animated: true)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
    }

    @IBAction func logoutButtonPressed(_ sender: Any) {
        FirebaseClient.shared.logout(vc: self)
    }
    
    @IBAction func createEventButtonPressed(_ sender: Any) {
        
        let createEventVC = storyboard?.instantiateViewController(withIdentifier: "CreateEventViewController") as! CreateEventViewController
        self.navigationController?.pushViewController(createEventVC, animated: true)
        
    }
    
    
}

extension EventsViewController: UISearchResultsUpdating {
    func updateSearchResults(for: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
