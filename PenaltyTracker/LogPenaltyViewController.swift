//
//  LogPenaltyViewController.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/6/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class LogPenaltyViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var eventID: String?
    var penalty: Penalty?
    var navBarHeight: CGFloat!
    
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    
    @IBOutlet weak var bibNumberTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var bikeTypeTextField: UITextField!
    @IBOutlet weak var bikeColorTextField: UITextField!
    @IBOutlet weak var helmetColorTextField: UITextField!
    
    @IBOutlet weak var topColorTextField: UITextField!
    @IBOutlet weak var pantColorTextField: UITextField!
    
    @IBOutlet weak var penaltyTextField: UITextField!
    @IBOutlet weak var bikeLengthsTextField: UITextField!
    @IBOutlet weak var secondsTextField: UITextField!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var approximateMileTextField: UITextField!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    
    var toolBar: UIToolbar!
    
    var bikePicker: UIPickerView!
    var bikes: [String] = []
    
    var bikeColorPicker: UIPickerView!
    var helmetColorPicker: UIPickerView!
    var topColorPicker: UIPickerView!
    var pantColorPicker: UIPickerView!
    var colors: [String] = []
    
    var penaltyTypePicker: UIPickerView!
    var penaltyTypes: [PenaltyType] = []
    
    var bikeLengthsPicker: UIPickerView!
    let bikeLengths = Array(1...5)
    
    var secondsPicker: UIPickerView!
    let seconds = Array(1...60)
    
    var approximateMilePicker: UIPickerView!
    let approximateMiles = Array(1...120)
    
    var currentTextField: UITextField?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarHeight = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        genderSegmentedControl.tintColor = appDelegate.darkBlueColor
        
        bikeLengthsTextField.isEnabled = false
        secondsTextField.isEnabled = false
        
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.lightGray.cgColor
        cardView.layer.cornerRadius = 5
        
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        notesTextView.layer.cornerRadius = 5
        
        stackView.isHidden = true
        
        aiv.isHidden = false
        aiv.startAnimating()
        
        if GlobalFunctions.shared.hasConnectivity() {
            FirebaseClient.shared.getDescriptors() { (bikes, colors, penaltyTypes, error) -> () in
                self.aiv.isHidden = true
                self.aiv.stopAnimating()
                self.stackView.isHidden = false
                if let bikes = bikes, let colors = colors, let penaltyTypes = penaltyTypes {
                    self.bikes = bikes
                    self.colors = colors
                    self.penaltyTypes = penaltyTypes
                    self.setUpTextFields()
                } else {
                    print("error")
                }
            }
        } else {
            self.displayAlert(title: "No Internet Connectivity", message: "Establish an Internet Connection and try again.")
        }
        
        submitButton.setTitleColor(appDelegate.darkBlueColor, for: .normal)
        
        if let penalty = penalty {
            bibNumberTextField.text = penalty.bibNumber
            if penalty.gender == "M" {
                genderSegmentedControl.selectedSegmentIndex = 0
            } else {
                genderSegmentedControl.selectedSegmentIndex = 1
            }
            bikeTypeTextField.text = penalty.bikeType
            bikeColorTextField.text = penalty.bikeColor
            helmetColorTextField.text = penalty.helmetColor
            topColorTextField.text = penalty.topColor
            pantColorTextField.text = penalty.pantColor
            penaltyTextField.text = penalty.penalty
            bikeLengthsTextField.text = penalty.bikeLengths
            secondsTextField.text = penalty.seconds
            approximateMileTextField.text = penalty.approximateMile
            notesTextView.text = penalty.notes
            if ["Blatant Littering", "Drafting"].contains(penalty.penalty) {
                cardView.backgroundColor = appDelegate.darkBlueColor
                cardLabel.text = "Blue Card"
                cardLabel.textColor = .white
            } else {
                cardView.backgroundColor = appDelegate.yellowColor
                cardLabel.text = "Yellow Card"
                cardLabel.textColor = .black
            }
            submitButton.setTitle("SUBMIT CHANGES", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        unsubscribeFromKeyboardNotifications()
    }
    
    func setUpTextFields() {
        toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        toolBar.barStyle = .default
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        
        toolBar.items = [flex, done]
        
        bibNumberTextField.inputAccessoryView = toolBar
        
        bikePicker = createPicker()
        setUpInputView(textField: bikeTypeTextField, picker: bikePicker, toolBar: toolBar)
        
        bikeColorPicker = createPicker()
        setUpInputView(textField: bikeColorTextField, picker: bikeColorPicker, toolBar: toolBar)
        helmetColorPicker = createPicker()
        setUpInputView(textField: helmetColorTextField, picker: helmetColorPicker, toolBar: toolBar)
        topColorPicker = createPicker()
        setUpInputView(textField: topColorTextField, picker: topColorPicker, toolBar: toolBar)
        pantColorPicker = createPicker()
        setUpInputView(textField: pantColorTextField, picker: pantColorPicker, toolBar: toolBar)
        
        penaltyTypePicker = createPicker()
        setUpInputView(textField: penaltyTextField, picker: penaltyTypePicker, toolBar: toolBar)
        
        bikeLengthsPicker = createPicker()
        setUpInputView(textField: bikeLengthsTextField, picker: bikeLengthsPicker, toolBar: toolBar)
        
        secondsPicker = createPicker()
        setUpInputView(textField: secondsTextField, picker: secondsPicker, toolBar: toolBar)
        
        approximateMilePicker = createPicker()
        setUpInputView(textField: approximateMileTextField, picker: approximateMilePicker, toolBar: toolBar)
        
        notesTextView.inputAccessoryView = toolBar
        
    }
    
    func createPicker() -> UIPickerView {
        return UIPickerView(frame: CGRect(x: 0, y: toolBar.frame.size.height, width: screenWidth, height: 150))
    }
    
    func setUpInputView(textField: UITextField, picker: UIPickerView, toolBar: UIToolbar) {
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
        let view = UIView(frame:CGRect(x: 0, y: 0, width: screenWidth, height: toolBar.frame.size.height + picker.frame.size.height))
        view.backgroundColor = .clear
        view.addSubview(picker)
        textField.inputView = view
        textField.inputAccessoryView = toolBar
    }
    
    func dismissKeyboard() {
        currentTextField?.resignFirstResponder()
        notesTextView.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
        if notesTextView.isFirstResponder {
            view.frame.origin.y = (-1*getKeyboardHeight(notification: notification))+navBarHeight
        } else if approximateMileTextField.isFirstResponder || secondsTextField.isFirstResponder || bikeLengthsTextField.isFirstResponder || penaltyTextField.isFirstResponder {
            view.frame.origin.y = (-1*getKeyboardHeight(notification: notification)+navBarHeight)/2
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
    
    //PickerView Delegate methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == bikePicker {
            return bikes.count
        } else if pickerView == approximateMilePicker {
            return approximateMiles.count
        } else if pickerView == penaltyTypePicker {
            return penaltyTypes.count
        } else if pickerView == bikeLengthsPicker {
            return bikeLengths.count
        } else if pickerView == secondsPicker {
            return seconds.count
        } else {
            return colors.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == bikePicker {
            return bikes[row]
        } else if pickerView == approximateMilePicker {
            return String(approximateMiles[row])
        } else if pickerView == penaltyTypePicker {
            return penaltyTypes[row].name
        } else if pickerView == bikeLengthsPicker {
            return String(bikeLengths[row])
        } else if pickerView == secondsPicker {
            return String(seconds[row])
        } else {
            return colors[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == bikePicker {
            currentTextField?.text = bikes[row]
        } else if pickerView == approximateMilePicker {
            currentTextField?.text = String(approximateMiles[row])
        } else if pickerView == penaltyTypePicker {
            currentTextField?.text = penaltyTypes[row].name
            if penaltyTypes[row].name == "Drafting" {
                bikeLengthsTextField.isEnabled = true
                bikeLengthsTextField.text = ""
                secondsTextField.isEnabled = true
                secondsTextField.text = ""
            } else {
                bikeLengthsTextField.isEnabled = false
                secondsTextField.isEnabled = false
            }
            if penaltyTypes[row].color == "Blue" {
                cardView.backgroundColor = appDelegate.darkBlueColor
                cardLabel.text = "Blue Card"
                cardLabel.textColor = .white
            } else if penaltyTypes[row].color == "Yellow" {
                cardView.backgroundColor = appDelegate.yellowColor
                cardLabel.text = "Yellow Card"
                cardLabel.textColor = .black
            } else {
                cardView.backgroundColor = .white
                cardLabel.text = "Card"
                cardLabel.textColor = .black
            }
        } else if pickerView == bikeLengthsPicker {
            currentTextField?.text = String(bikeLengths[row])
        } else if pickerView == secondsPicker {
            currentTextField?.text = String(seconds[row])
        } else {
            currentTextField?.text = colors[row]
        }
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        
        if bibNumberTextField.text! == "" {
            displayAlert(title: "No Bib Number", message: "You must provide a Bib Number.")
            return
        }
        
        if penaltyTextField.text! == "" {
            displayAlert(title: "No Penalty", message: "You must provide the name of the penalty.")
            return
        }
        
        if penaltyTextField.text! == "Drafting" {
            if bikeLengthsTextField.text == "" {
                displayAlert(title: "No Bike Lengths", message: "You must specify bike lengths for a drafting penalty.")
                return
            }
            if secondsTextField.text == "" {
                displayAlert(title: "No Seconds", message: "You must provide the number of seconds for a drafting penalty.")
                return
            }
        }
        
        if approximateMileTextField.text! == "" {
            displayAlert(title: "No Approximate Mile", message: "You must provide an approximate mile.")
            return
        }
        
        let bibNumber = bibNumberTextField.text!
        let gender = genderSegmentedControl.titleForSegment(at: genderSegmentedControl.selectedSegmentIndex)!
        let bikeType = bikeTypeTextField.text!
        let bikeColor = bikeColorTextField.text!
        let helmetColor = helmetColorTextField.text!
        let topColor = topColorTextField.text!
        let pantColor = pantColorTextField.text!
        let penalty = penaltyTextField.text!
        let bikeLengths = bikeLengthsTextField.text!
        let seconds = secondsTextField.text!
        let approximateMile = approximateMileTextField.text!
        let submittedBy = appDelegate.currentUser?.name
        let notes = notesTextView.text!
        var existingPenaltyUid = ""
        if let existingPenalty = self.penalty {
            existingPenaltyUid = existingPenalty.uid
        }
        
        var newPenalty = Penalty(uid: existingPenaltyUid, bibNumber: bibNumber, gender: gender, bikeType: bikeType, bikeColor: bikeColor, helmetColor: helmetColor, topColor: topColor, pantColor: pantColor, penalty: penalty, bikeLengths: bikeLengths, seconds: seconds, approximateMile: approximateMile, notes: notes, submittedBy: submittedBy!, timeStamp: "", checkedIn: false)
        
        var penaltyMessage = ""
        if penalty == "Drafting" {
            if bikeLengths == "1" {
                penaltyMessage = "\(penalty) (\(bikeLengths) length, \(seconds) s)"
            } else {
                penaltyMessage = "\(penalty) (\(bikeLengths) lengths, \(seconds) s)"
            }
        } else {
            penaltyMessage = penalty
        }
        
        let message = "Does everything look correct? \n\n Bib Number: \(bibNumber) \n Gender: \(gender) \n Bike Type: \(bikeType) \n Bike Color: \(bikeColor) \n Helmet Color: \(helmetColor) \n Top Color: \(topColor) \n Pant Color: \(pantColor) \n Penalty: \(penaltyMessage) \n Approximate Mile: \(approximateMile)"
        
        let confirmPenaltyDetails = UIAlertController(title: "Confirm Penalty Details", message: message, preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            if existingPenaltyUid == "" {
                newPenalty.timeStamp = self.getCurrentDateAndTime()
            } else {
                newPenalty.timeStamp = (self.penalty?.timeStamp)!
            }
            if GlobalFunctions.shared.hasConnectivity() {
                FirebaseClient.shared.postPenalty(eventID: (self.eventID)!, penaltyID: existingPenaltyUid, penalty: newPenalty) { (success, message) -> () in
                    if let success = success, let message = message {
                        if success {
                            let alert = UIAlertController(title: "Success!", message: message as String, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                                if existingPenaltyUid == "" {
                                    self.navigationController?.popViewController(animated: true)
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
        
        confirmPenaltyDetails.addAction(cancelAction)
        confirmPenaltyDetails.addAction(submitAction)
        
        self.present(confirmPenaltyDetails, animated: false, completion: nil)
        
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    
    func getCurrentDateAndTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd HH:mm:ss:SSS"
        let stringDate = formatter.string(from: date)
        return stringDate
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool  {
        
        if textField == bibNumberTextField {
            let currentCharacterCount = textField.text?.characters.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.characters.count - range.length
            return newLength <= 9
        }
        
        return true
    }
    
}
