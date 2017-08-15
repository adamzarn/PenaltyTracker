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
    @IBOutlet weak var pin1: UITextField!
    @IBOutlet weak var pin2: UITextField!
    @IBOutlet weak var pin3: UITextField!
    @IBOutlet weak var pin4: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var event: Event?
    
    var statePicker: UIPickerView!
    let stateOptions = ["", "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL",
                        "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT",
                        "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                        "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let formatter = DateFormatter()
    
    var currentTextField: UITextField?
    
    var navBarHeight: CGFloat!
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.visibleDates { (visibleDates) in
            self.setUpHeader(from: visibleDates)
            if let event = self.event {
                let formatter = DateFormatter()
                formatter.dateFormat = "M/d/yy"
                let date = formatter.date(from: event.date)
                self.calendarView.scrollToDate(date!)
            }
        }
        
        navBarHeight = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        
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
        
        pin1.inputAccessoryView = toolBar
        pin2.inputAccessoryView = toolBar
        pin3.inputAccessoryView = toolBar
        pin4.inputAccessoryView = toolBar
        
        submitButton.setTitleColor(appDelegate.darkBlueColor, for: .normal)
        
        if let event = self.event {
            self.navigationItem.title = "Edit Event"
            nameTextField.text = event.name
            cityTextField.text = event.city
            stateTextField.text = event.state
            let pinDigits = GlobalFunctions.shared.parse(pin: event.pin)
            pin1.text = pinDigits[0]
            pin2.text = pinDigits[1]
            pin3.text = pinDigits[2]
            pin4.text = pinDigits[3]
            submitButton.setTitle("SUBMIT CHANGES", for: .normal)
        }
        
    }
    
    func selectDate(of event: Event) {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        let date = formatter.date(from: event.date)
        self.calendarView.selectDates([date!])
        self.calendarView.reloadData()
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
        
        currentTextField?.resignFirstResponder()
        
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
        let selectedDate = calendarView.selectedDates[0]
        formatter.dateFormat = "yyyyMMdd HH:mm:ss:SSS"
        let date = formatter.string(from: selectedDate)
        let createdDate = formatter.string(from: Date())
        let pin = "\(pin1.text!)\(pin2.text!)\(pin3.text!)\(pin4.text!)"
        let admin = Auth.auth().currentUser?.uid
        let adminName = appDelegate.currentUser?.name
        var existingEventUid = ""
        if let existingEvent = self.event {
            existingEventUid = existingEvent.uid
        }
        
        let event = Event(uid: existingEventUid, name: name, pin: pin, city: city, state: state, date: date, createdDate: createdDate, admin: admin!, adminName: adminName!)
        
        let message = "Does everything look correct? \n\n Event: \(name) \n Location: \(city), \(state) \n Date: \(GlobalFunctions.shared.formattedTimestamp(ts: date, includeDate: true, includeTime: false)) \n PIN: \(pin) \n Created by: \(adminName!)"
        
        let confirmEventDetails = UIAlertController(title: "Confirm Event Details", message: message, preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            
            if GlobalFunctions.shared.hasConnectivity() {
            
                FirebaseClient.shared.createEvent(uid: existingEventUid, event: event) { (success, message) -> () in
                    if let success = success, let message = message {
                        if success {
                            let alert = UIAlertController(title: "Success!", message: message as String,  preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Sure", style: .default) { (_) in
                                self.nameTextField.text = ""
                                self.cityTextField.text = ""
                                self.stateTextField.text = ""
                                self.calendarView.deselectAllDates()
                                self.pin1.text = ""
                                self.pin2.text = ""
                                self.pin3.text = ""
                                self.pin4.text = ""
                                let selectRecipientsVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectRecipientsViewController") as! SelectRecipientsViewController
                                selectRecipientsVC.subject = "PenaltyTracker Event Invite"
                                selectRecipientsVC.emailBody = "Hello,\nYou've been invited to officiate an event called \"\(event.name)\" with PenaltyTracker. Follow the steps below to get started.\n\n1. Open/Download the PenaltyTracker App.\n2. Create an account or login.\n3. Search for \"\(event.name)\" in the events page and select it.\n4. When asked to enter a PIN, enter \(event.pin).\n\nThat's it. We hope you enjoy issuing penalties with PenaltyTracker!"
                                self.navigationController?.pushViewController(selectRecipientsVC, animated: false)
                            })
                            alert.addAction(UIAlertAction(title: "Not right now", style: .default) { (_) in
                                if existingEventUid == "" {
                                    self.navigationController?.popToRootViewController(animated: true)
                                } else {
                                    let penaltiesTableVC = self.navigationController?.viewControllers[1] as! PenaltiesTableViewController
                                    penaltiesTableVC.event = event
                                }
                            })
                            self.present(alert, animated: false, completion: nil)
                        } else {
                            self.displayAlert(title: "Error", message: "We were unable to complete your request. Please try again.")
                        }
                    } else {
                        self.displayAlert(title: "Error", message: "We were unable to complete your request. Please try again.")
                    }
                }
                
            } else {
                    
                self.displayAlert(title: "No Internet Connectivity", message: "Establish an Internet Connection and try again.")
                    
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
            view.frame.origin.y = (-1*getKeyboardHeight(notification: notification)) + navBarHeight
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        view.frame.origin.y = navBarHeight
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
        return stateOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = .center
        let title = stateOptions[row]
        let myTitle = NSAttributedString(string: title, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 32.0),NSForegroundColorAttributeName: UIColor.black])
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        stateTextField.text = stateOptions[row]
    }
    
}

extension CreateEventViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 720, to: startDate)!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
        return parameters
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
        let calendarDate = formatDate(date: date)
        let currentDate = formatDate(date: Date())
        
        if (calendarView.visibleDates().monthDates.first?.date)! > calendarDate || (calendarView.visibleDates().monthDates.last?.date)! < calendarDate {
            cell.isUserInteractionEnabled = false
        }
        
        if calendarDate < currentDate {
            cell.dateLabel.textColor = .lightGray
            cell.isUserInteractionEnabled = false
        } else {
            cell.dateLabel.textColor = .black
            cell.isUserInteractionEnabled = true
        }
        
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.text = cellState.text
            cell.isUserInteractionEnabled = true
        } else {
            cell.dateLabel.text = ""
            cell.isUserInteractionEnabled = false
        }
        
        if cellState.isSelected && cellState.dateBelongsTo == .thisMonth {
            print(date)
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
        if let event = self.event {
            selectDate(of: event)
        }
    }
    
    
}
