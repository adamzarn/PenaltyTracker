//
//  CreateEventViewController.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/4/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase
import JTAppleCalendar

class CreateEventViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var startTimeTextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var pin1: UITextField!
    @IBOutlet weak var pin2: UITextField!
    @IBOutlet weak var pin3: UITextField!
    @IBOutlet weak var pin4: UITextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.visibleDates { (visibleDates) in
            self.setUpHeader(from: visibleDates)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(false)
        unsubscribeFromKeyboardNotifications()
    }
    
    func setUpHeader(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "MMMM yyyy"
        monthLabel.text = formatter.string(from: date)
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        
        let name = nameTextField.text!
        let city = cityTextField.text!
        let state = stateTextField.text!
        let startTime = startTimeTextField.text!
        let endTime = endTimeTextField.text!
        let selectedDate = calendarView.selectedDates[0]
        formatter.dateFormat = "M/d/yy"
        let date = formatter.string(from: selectedDate)
        let pin = "\(pin1.text!)\(pin2.text!)\(pin3.text!)\(pin4.text!)"
        let admin = Auth.auth().currentUser?.uid
        let adminName = appDelegate.currentUser?.name
        
        let event = Event(name: name, pin: pin, city: city, state: state, date: date, startTime: startTime, endTime: endTime, admin: admin!, adminName: adminName!)
        
        let message = "Does everything look correct? \n\n Event: \(name) \n Location: \(city), \(state) \n Start Time: \(startTime) \n End Time: \(endTime) \n PIN: \(pin) \n Created by: \(adminName!)"
        
        let confirmEventDetails = UIAlertController(title: "Confirm Event Details", message: message, preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in

            FirebaseClient.shared.createEvent(event: event) { (success) -> () in
                if let success = success {
                    if success {
                        let alert = UIAlertController(title: "Success!", message: "Your event was successfully created. We'll take you to the Events list now where you can access it.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                        self.present(alert, animated: false, completion: nil)
                    } else {
                        self.displayAlert(title: "Error", message: "We were unable to create your event. Please try again.")
                    }
                } else {
                    self.displayAlert(title: "Error", message: "We were unable to create your event. Please try again.")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        confirmEventDetails.addAction(cancelAction)
        confirmEventDetails.addAction(submitAction)
        
        self.present(confirmEventDetails, animated: false, completion: nil)

    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    
    //Adjusting keyboard methods
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide),name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func keyboardWillShow(notification: Notification) {
        if pin1.isFirstResponder || pin2.isFirstResponder || pin3.isFirstResponder || pin4.isFirstResponder {
            view.frame.origin.y = (-1*getKeyboardHeight(notification: notification)) + (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        view.frame.origin.y = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
    }
    
    func getKeyboardHeight(notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    //Text Field Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension CreateEventViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = Date()
        let endDate = formatter.date(from: "2100 12 31")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.text = cellState.text
            cell.isUserInteractionEnabled = true
        } else {
            cell.dateLabel.text = ""
            cell.isUserInteractionEnabled = false
        }
        
        let calendarDate = formatDate(date: date)
        let currentDate = formatDate(date: Date())
        
        if calendarDate < currentDate {
            cell.dateLabel.textColor = .lightGray
            cell.isUserInteractionEnabled = false
        } else {
            cell.dateLabel.textColor = .black
            cell.isUserInteractionEnabled = true
        }
        
        if cellState.isSelected && cellState.dateBelongsTo == .thisMonth {
            cell.selectedView.isHidden = false
        } else {
            cell.selectedView.isHidden = true
        }
        return cell
    }
    
    func formatDate(date: Date) -> Date {
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return Calendar.current.date(from: dateComponents)!
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else { return }
        if validCell.dateLabel.textColor == .black && cellState.dateBelongsTo == .thisMonth {
            validCell.selectedView.isHidden = false
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let validCell = cell as? CalendarCell else { return }
        if validCell.dateLabel.textColor == .black && cellState.dateBelongsTo == .thisMonth {
            validCell.selectedView.isHidden = true
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        setUpHeader(from: visibleDates)
        
    }
    
    
}
