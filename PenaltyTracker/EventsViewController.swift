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
    let defaults = UserDefaults.standard
    var accessibleEvents: [String] = []
    
    var events: [Event] = []
    var filteredEvents: [Event] = []

    @IBOutlet weak var enterPinView: UIView!
    var dimView: UIView?
    @IBOutlet weak var forEventNameLabel: UILabel!
    @IBOutlet weak var pin1: PinField!
    @IBOutlet weak var pin2: PinField!
    @IBOutlet weak var pin3: PinField!
    @IBOutlet weak var pin4: PinField!
    @IBOutlet weak var submitPinButton: UIButton!
    @IBOutlet weak var cancelPinButton: UIButton!
    
    
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    @IBOutlet weak var welcomeToolbar: UIToolbar!
    @IBOutlet weak var welcomeButton: UIBarButtonItem!
    
    @IBOutlet weak var myTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var currentTextField: UITextField?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var correctPin: String?
    var eventRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.setContentOffset(CGPoint(x:0,y:searchController.searchBar.frame.size.height), animated: false)
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = false
        searchController.hidesNavigationBarDuringPresentation = false
        myTableView.tableHeaderView = searchController.searchBar
        
        dimView = UIView(frame:UIScreen.main.bounds)
        dimView?.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        
        enterPinView.layer.cornerRadius = 5
        submitPinButton.setTitleColor(appDelegate.darkBlueColor, for: .normal)
        cancelPinButton.setTitleColor(appDelegate.darkBlueColor, for: .normal)
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        toolBar.barStyle = .default
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolBar.items = [flex, done]
        
        pin1.inputAccessoryView = toolBar
        pin2.inputAccessoryView = toolBar
        pin3.inputAccessoryView = toolBar
        pin4.inputAccessoryView = toolBar
        
        pin1.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        pin2.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        pin3.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        welcomeToolbar.isUserInteractionEnabled = false
        if let user = appDelegate.currentUser {
            welcomeButton.title = "Welcome \(user.name)!"
        } else {
            welcomeButton.title = "Welcome!"
        }
        welcomeButton.tintColor = appDelegate.darkBlueColor
    
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if searchController.isActive {
            if Auth.auth().currentUser?.uid == filteredEvents[indexPath.row].admin {
                return true
            }
        } else {
            if Auth.auth().currentUser?.uid == events[indexPath.row].admin {
                return true
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var event = events[indexPath.row]
            if searchController.isActive {
                event = filteredEvents[indexPath.row]
            }
            let alert = UIAlertController(title: "Delete Event", message: "This can't be undone. Are you sure you want to continue?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { (_) in
                if GlobalFunctions.shared.hasConnectivity() {
                    FirebaseClient.shared.deleteEvent(eventID: event.uid) { (success) -> () in
                        if let success = success {
                            if success {
                                self.displayAlert(title: "Success", message: "The event was successfully deleted.")
                                self.loadEvents()
                            } else {
                                self.displayAlert(title: "Error", message: "The event couldn't be deleted.")
                            }
                        } else {
                            self.displayAlert(title: "Error", message: "The event couldn't be deleted.")
                        }
                    }
                } else {
                    self.displayAlert(title: "No Internet Connectivity", message: "Establish an Internet Connection and try again.")
                }
            })
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        enterPinView.isHidden = true
        myTableView.isHidden = true
        loadingLabel.isHidden = false
        aiv.isHidden = false
        aiv.startAnimating()
        NotificationCenter.default.addObserver(self, selector: #selector(EventsViewController.deletePressed), name: NSNotification.Name(rawValue: "deletePressed"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "deletePressed"), object: nil)
    }
    
    func deletePressed() {
        if pin1.isFirstResponder {
            pin1.text = ""
        } else if pin2.isFirstResponder {
            pin2.text = ""
            pin1.becomeFirstResponder()
        } else if pin3.isFirstResponder {
            pin3.text = ""
            pin2.becomeFirstResponder()
        } else if pin4.isFirstResponder {
            pin4.text = ""
            pin3.becomeFirstResponder()
            return
        }
    }
    
    func loadEvents() {
        
        if GlobalFunctions.shared.hasConnectivity() {
            FirebaseClient.shared.getEvents() { (events, error) -> () in
                if let events = events {
                    self.events = events
                    self.events.sort { $0.date < $1.date }
                } else {
                    print(error!)
                }
                self.myTableView.reloadData()
                self.myTableView.isHidden = false
            }
        } else {
            self.displayAlert(title: "No Internet Connectivity", message: "Establish an Internet Connection and try again.")
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
        loadEvents()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredEvents.count
        }
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCell
        if searchController.isActive {
            cell.setUpCell(event: filteredEvents[indexPath.row])
        } else {
            cell.setUpCell(event: events[indexPath.row])
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.accessibleEvents = []
        if let accessibleEvents = defaults.array(forKey: "accessibleEvents") {
            self.accessibleEvents = accessibleEvents as! [String]
        }
        
        var selectedEvent: Event!
        if searchController.isActive {
            selectedEvent = filteredEvents[indexPath.row]
        } else {
            selectedEvent = events[indexPath.row]
        }
        
        if (self.accessibleEvents).contains(selectedEvent.uid) {
            accessEvent(row: indexPath.row)
        } else if selectedEvent.admin == Auth.auth().currentUser?.uid {
            accessEvent(row: indexPath.row)
        } else {
            correctPin = selectedEvent.pin
            forEventNameLabel.text = "for \(selectedEvent.name)"
            eventRow = indexPath.row
            pin1.becomeFirstResponder()
            tableView.deselectRow(at: indexPath, animated: false)
            self.view.addSubview(dimView!)
            self.view.bringSubview(toFront: dimView!)
            enterPinView.isHidden = false
            self.view.bringSubview(toFront: enterPinView)
        }
    }
    
    func accessEvent(row: Int) {
        if !self.accessibleEvents.contains(events[row].uid) {
            self.accessibleEvents.append(events[row].uid)
        }
        defaults.set(self.accessibleEvents, forKey: "accessibleEvents")
        let penaltiesVC = storyboard?.instantiateViewController(withIdentifier: "PenaltiesTableViewController") as! PenaltiesTableViewController
        if searchController.isActive {
            penaltiesVC.event = filteredEvents[row]
        } else {
            penaltiesVC.event = events[row]
        }
        prepareForTransition()
        self.navigationController?.pushViewController(penaltiesVC, animated: true)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredEvents = events.filter { event in
            return (event.name.contains(searchText) || event.city.contains(searchText))
        }
        myTableView.reloadData()
    }

    @IBAction func logoutButtonPressed(_ sender: Any) {
        FirebaseClient.shared.logout(vc: self)
    }
    
    @IBAction func createEventButtonPressed(_ sender: Any) {
        prepareForTransition()
        let createEventVC = storyboard?.instantiateViewController(withIdentifier: "CreateEventViewController") as! CreateEventViewController
        self.navigationController?.pushViewController(createEventVC, animated: true)
        
    }
    
    func prepareForTransition() {
        dismissEnterPinView()
        myTableView.isHidden = true
        aiv.isHidden = true
        loadingLabel.isHidden = true
        if searchController.isActive {
            searchController.searchBar.text = ""
            searchController.isActive = false
            searchController.dismiss(animated: false, completion: nil)
        }
    }
    
    func dismissKeyboard() {
        currentTextField?.resignFirstResponder()
    }
    
    //Text Field Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if [pin1, pin2, pin3, pin4].contains(textField) {
            textField.text = ""
        }
        currentTextField = textField
        textField.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool  {
        
        if [pin1, pin2, pin3, pin4].contains(textField) {
            let currentCharacterCount = textField.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.characters.count - range.length
            return newLength <= 1
        }
        
        return true
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if textField == pin1 {
            pin2.becomeFirstResponder()
        } else if textField == pin2 {
            pin3.becomeFirstResponder()
        } else if textField == pin3 {
            pin4.becomeFirstResponder()
        }
    }
    

    @IBAction func submitPinButtonPressed(_ sender: Any) {

        let enteredPin = "\(pin1.text!)\(pin2.text!)\(pin3.text!)\(pin4.text!)"
        clearPinEntries()
        if enteredPin == correctPin! {
            accessEvent(row: eventRow!)
        } else {
            pin1.becomeFirstResponder()
            displayAlert(title: "Incorrect PIN", message: "Contact this event's administrator for the PIN.")
        }
            
    }
    
    @IBAction func cancelPinButtonPressed(_ sender: Any) {
        clearPinEntries()
        dismissEnterPinView()
    }
    
    func clearPinEntries() {
        pin1.text = ""
        pin2.text = ""
        pin3.text = ""
        pin4.text = ""
    }
    
    func dismissEnterPinView() {
        currentTextField?.resignFirstResponder()
        enterPinView.isHidden = true
        dimView?.removeFromSuperview()
    }
    
}

extension EventsViewController: UISearchResultsUpdating {
    func updateSearchResults(for: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
