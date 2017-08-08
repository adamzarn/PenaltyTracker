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

class CreateEventViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    @IBOutlet weak var submitButton: UIButton!
    
    var statePicker: UIPickerView!
    let stateOptions = ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL",
                        "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT",
                        "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                        "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
    
    var timePicker: UIPickerView!
    let timeOptions = ["12:00 AM", "12:15 AM", "12:30 AM", "12:45 AM",
                       "1:00 AM",  "1:15 AM",  "1:30 AM",  "1:45 AM",
                       "2:00 AM",  "2:15 AM",  "2:30 AM",  "2:45 AM",
                       "3:00 AM",  "3:15 AM",  "3:30 AM",  "3:45 AM",
                       "4:00 AM",  "4:15 AM",  "4:30 AM",  "4:45 AM",
                       "5:00 AM",  "5:15 AM",  "5:30 AM",  "5:45 AM",
                       "6:00 AM",  "6:15 AM",  "6:30 AM",  "6:45 AM",
                       "7:00 AM",  "7:15 AM",  "7:30 AM",  "7:45 AM",
                       "8:00 AM",  "8:15 AM",  "8:30 AM",  "8:45 AM",
                       "9:00 AM",  "9:15 AM",  "9:30 AM",  "9:45 AM",
                       "10:00 AM", "10:15 AM", "10:30 AM", "10:45 AM",
                       "11:00 AM", "11:15 AM", "11:30 AM", "11:45 AM",
                       "12:00 PM", "12:15 PM", "12:30 PM", "12:45 PM",
                       "1:00 PM",  "1:15 PM",  "1:30 PM",  "1:45 PM",
                       "2:00 PM",  "2:15 PM",  "2:30 PM",  "2:45 PM",
                       "3:00 PM",  "3:15 PM",  "3:30 PM",  "3:45 PM",
                       "4:00 PM",  "4:15 PM",  "4:30 PM",  "4:45 PM",
                       "5:00 PM",  "5:15 PM",  "5:30 PM",  "5:45 PM",
                       "6:00 PM",  "6:15 PM",  "6:30 PM",  "6:45 PM",
                       "7:00 PM",  "7:15 PM",  "7:30 PM",  "7:45 PM",
                       "8:00 PM",  "8:15 PM",  "8:30 PM",  "8:45 PM",
                       "9:00 PM",  "9:15 PM",  "9:30 PM",  "9:45 PM",
                       "10:00 PM", "10:15 PM", "10:30 PM", "10:45 PM",
                       "11:00 PM", "11:15 PM", "11:30 PM", "11:45 PM"]

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let formatter = DateFormatter()
    
    var currentTextField: UITextField?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.visibleDates { (visibleDates) in
            self.setUpHeader(from: visibleDates)
        }
        
        pin1.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        pin2.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        pin3.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        toolBar.barStyle = .default
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        
        toolBar.items = [flex, done]
        
        statePicker = UIPickerView(frame: CGRect(x: 0, y: toolBar.frame.size.height, width: screenWidth, height: 150))
        statePicker.delegate = self
        statePicker.dataSource = self
        statePicker.showsSelectionIndicator = true
        
        let stateInputView = UIView(frame:CGRect(x: 0, y: 0, width: screenWidth, height: toolBar.frame.size.height + statePicker.frame.size.height))
        stateInputView.backgroundColor = .clear
        stateInputView.addSubview(statePicker)
        stateTextField.inputView = stateInputView
        stateTextField.inputAccessoryView = toolBar
        
        timePicker = UIPickerView(frame: CGRect(x: 0, y: toolBar.frame.size.height, width: screenWidth, height: 150))
        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.showsSelectionIndicator = true
        
        let timeInputView = UIView(frame:CGRect(x: 0, y: 0, width: screenWidth, height: toolBar.frame.size.height + statePicker.frame.size.height))
        timeInputView.backgroundColor = .clear
        timeInputView.addSubview(timePicker)
        
        startTimeTextField.inputView = timeInputView
        startTimeTextField.inputAccessoryView = toolBar
        endTimeTextField.inputView = timeInputView
        endTimeTextField.inputAccessoryView = toolBar
        
        pin1.inputAccessoryView = toolBar
        pin2.inputAccessoryView = toolBar
        pin3.inputAccessoryView = toolBar
        pin4.inputAccessoryView = toolBar
        
        submitButton.setTitleColor(appDelegate.darkBlueColor, for: .normal)
        
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
        
        if nameTextField.text! == "" {
            displayAlert(title: "No Name", message: "You must give this event a name.")
            return
        }
        
        if cityTextField.text! == "" {
            displayAlert(title: "No City", message: "You must specify a city for this event.")
            return
        }
        
        if stateTextField.text! == "" {
            displayAlert(title: "No State", message: "You must specify a state for this event.")
            return
        }
        
        if startTimeTextField.text! == "" {
            displayAlert(title: "No Start Time", message: "You must specify a start time for this event.")
            return
        }
        
        if endTimeTextField.text! == "" {
            displayAlert(title: "No End Time", message: "You must specify an end time for this event.")
            return
        }
        
        let start = timeOptions.index(of: startTimeTextField.text!)!
        let end = timeOptions.index(of: endTimeTextField.text!)!
        
        if start >= end {
            displayAlert(title: "Bad Start and End Times", message: "The start time must be before the end time.")
            return
        }
        
        if calendarView.selectedDates.count == 0 {
            displayAlert(title: "No Date", message: "You must select a date for this event.")
            return
        }
        
        if pin1.text == "" || pin2.text == "" || pin3.text == "" || pin4.text == "" {
            displayAlert(title: "Bad Access PIN", message: "The Access PIN must contain 4 digits.")
            return
        }
    
        let name = nameTextField.text!
        let city = cityTextField.text!
        let state = stateTextField.text!
        let startTime = startTimeTextField.text!
        let endTime = endTimeTextField.text!
        let selectedDate = calendarView.selectedDates[0]
        formatter.dateFormat = "M/d/yy"
        let date = formatter.string(from: selectedDate)
        let createdDate = formatter.string(from: Date())
        let pin = "\(pin1.text!)\(pin2.text!)\(pin3.text!)\(pin4.text!)"
        let admin = Auth.auth().currentUser?.uid
        let adminName = appDelegate.currentUser?.name
        
        let event = Event(uid: "", name: name, pin: pin, city: city, state: state, date: date, createdDate: createdDate, startTime: startTime, endTime: endTime, admin: admin!, adminName: adminName!)
        
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
    
    //PickerView Delegate methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == statePicker {
            return stateOptions.count
        } else {
            return timeOptions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == statePicker {
            return stateOptions[row]
        } else {
            return timeOptions[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == statePicker {
            stateTextField.text = stateOptions[row]
        } else {
            currentTextField!.text = timeOptions[row]
        }
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
