//
//  LogPenaltyViewController.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/6/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class LogPenaltyViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UIScrollViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var eventID: String?
    var penalty: Penalty?
    var navBarHeight: CGFloat!
    var edits: [Edit] = []

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    
    @IBOutlet weak var bibNumberTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    
    @IBOutlet weak var appearanceLabel: UILabel!
    
    @IBOutlet weak var bikeTypeTextField: UITextField!
    @IBOutlet weak var bikeColorTextField: UITextField!
    @IBOutlet weak var helmetColorTextField: UITextField!
    
    @IBOutlet weak var topColorTextField: UITextField!
    @IBOutlet weak var pantColorTextField: UITextField!
    
    @IBOutlet weak var penaltyLabel: UILabel!
    
    @IBOutlet weak var penaltyTextField: UITextField!
    @IBOutlet weak var bikeLengthsTextField: UITextField!
    @IBOutlet weak var secondsTextField: UITextField!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var approximateMileTextField: UITextField!
    
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var editsLabel: UILabel!
    @IBOutlet weak var editsTableView: UITableView!
    
    @IBOutlet weak var submitButton: UIBarButtonItem!

    @IBOutlet weak var toolbar: UIToolbar!
    var doneToolbar: UIToolbar!
    
    var genderPicker: UIPickerView!
    var genders = ["Gender", "Male", "Female"]
    
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
    let bikeLengths = ["Bike Lengths","1","2","3","4","5"]
    
    var secondsPicker: UIPickerView!
    var seconds = ["Seconds","26","27","28","29","30","31","32","33","34","35","36","37","38",
                   "39","40","41","42","43","44","45","46","47","48","49","50","51",
                   "52","53","54","55","56","57","58","59","60+"]
    
    var approximateMilePicker: UIPickerView!
    let approximateMiles = ["Approximate Mile","1","2","3","4","5","6","7","8","9","10",
                            "11","12","13","14","15","16","17","18","19","20",
                            "21","22","23","24","25","26","27","28","29","30",
                            "31","32","33","34","35","36","37","38","39","40",
                            "41","42","43","44","45","46","47","48","49","50",
                            "51","52","53","54","55","56","57","58","59","60",
                            "61","62","63","64","65","66","67","68","69","70",
                            "71","72","73","74","75","76","77","78","79","80",
                            "81","82","83","84","85","86","87","88","89","90",
                            "91","92","93","94","95","96","97","98","99","100",
                            "101","102","103","104","105","106","107","108","109","110",
                            "111","112","113","114","115","116","117","118","119","120"]
    
    var pickers: [UIPickerView]!
    
    var currentTextField: UITextField?
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toolbar.isTranslucent = false
        
        navBarHeight = (self.navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.size.height
        
        bikeLengthsTextField.isEnabled = false
        secondsTextField.isEnabled = false
        
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.lightGray.cgColor
        cardView.layer.cornerRadius = 5
        
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        notesTextView.layer.cornerRadius = 5
        
        aiv.isHidden = false
        aiv.startAnimating()
        
        if GlobalFunctions.shared.hasConnectivity() {
            FirebaseClient.shared.getDescriptors() { (bikes, colors, penaltyTypes, error) -> () in
                self.aiv.isHidden = true
                self.aiv.stopAnimating()
                if let bikes = bikes, let colors = colors, let penaltyTypes = penaltyTypes {
                    self.bikes = bikes
                    self.bikes.insert("Bike Type", at: 0)
                    self.colors = colors
                    self.colors.insert("Color", at: 0)
                    self.penaltyTypes = penaltyTypes
                    self.penaltyTypes.insert(PenaltyType(name:"Penalty", color:""), at: 0)
                    self.setUpTextFields()
                } else {
                    print("error")
                }
            }
        } else {
            self.displayAlert(title: "No Internet Connectivity", message: "Establish an Internet Connection and try again.")
        }
        
        if let penalty = penalty {
            bibNumberTextField.text = penalty.bibNumber
            genderTextField.text = penalty.gender
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
            let editsDict = penalty.edits
            updateEditsArray(existingEdits: editsDict)
            submitButton.title = "SUBMIT CHANGES"
        }
        
        appearanceLabel.textColor = appDelegate.darkBlueColor
        penaltyLabel.textColor = appDelegate.darkBlueColor
        notesLabel.textColor = appDelegate.darkBlueColor
        editsLabel.textColor = appDelegate.darkBlueColor
        
        submitButton.tintColor = appDelegate.darkBlueColor
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        subscribeToKeyboardNotifications()
        pickers = [genderPicker, bikePicker, bikeColorPicker, helmetColorPicker, topColorPicker, pantColorPicker,penaltyTypePicker, bikeLengthsPicker, secondsPicker, approximateMilePicker]
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(false)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(LogPenaltyViewController.orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.contentView.frame.size.height)
        
        scrollView.isScrollEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(NSNotification.Name.UIDeviceOrientationDidChange)
    }
    
    func setUpTextFields() {
        doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        doneToolbar.barStyle = .default
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        
        doneToolbar.items = [flex, done]
        
        bibNumberTextField.inputAccessoryView = doneToolbar
        
        genderPicker = createPicker()
        setUpInputView(textField: genderTextField, picker: genderPicker, doneToolbar: doneToolbar)
        
        bikePicker = createPicker()
        setUpInputView(textField: bikeTypeTextField, picker: bikePicker, doneToolbar: doneToolbar)
        
        bikeColorPicker = createPicker()
        setUpInputView(textField: bikeColorTextField, picker: bikeColorPicker, doneToolbar: doneToolbar)
        helmetColorPicker = createPicker()
        setUpInputView(textField: helmetColorTextField, picker: helmetColorPicker, doneToolbar: doneToolbar)
        topColorPicker = createPicker()
        setUpInputView(textField: topColorTextField, picker: topColorPicker, doneToolbar: doneToolbar)
        pantColorPicker = createPicker()
        setUpInputView(textField: pantColorTextField, picker: pantColorPicker, doneToolbar: doneToolbar)
        
        penaltyTypePicker = createPicker()
        setUpInputView(textField: penaltyTextField, picker: penaltyTypePicker, doneToolbar: doneToolbar)
        
        bikeLengthsPicker = createPicker()
        setUpInputView(textField: bikeLengthsTextField, picker: bikeLengthsPicker, doneToolbar: doneToolbar)
        
        secondsPicker = createPicker()
        setUpInputView(textField: secondsTextField, picker: secondsPicker, doneToolbar: doneToolbar)
        
        approximateMilePicker = createPicker()
        setUpInputView(textField: approximateMileTextField, picker: approximateMilePicker, doneToolbar: doneToolbar)
        
        notesTextView.inputAccessoryView = doneToolbar
        
    }
    
    func orientationChanged() {
        if UIDevice.current.orientation.isPortrait {
            updatePickerWidths(width: screenWidth)
        } else {
            updatePickerWidths(width: screenHeight)
        }
    }
    
    func updatePickerWidths(width: CGFloat) {
        for picker in pickers {
            picker.frame.size.width = width
        }
    }
    
    func createPicker() -> UIPickerView {
        return UIPickerView(frame: CGRect(x: 0, y: doneToolbar.frame.size.height, width: screenWidth, height: 150))
    }
    
    func setUpInputView(textField: UITextField, picker: UIPickerView, doneToolbar: UIToolbar) {
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
        let view = UIView(frame:CGRect(x: 0, y: 0, width: screenWidth, height: doneToolbar.frame.size.height + picker.frame.size.height))
        view.backgroundColor = .clear
        view.addSubview(picker)
        textField.inputView = view
        textField.inputAccessoryView = doneToolbar
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
        if UIDevice.current.orientation.isPortrait {
            view.frame.origin.y = navBarHeight
        } else {
            view.frame.origin.y = navBarHeight/2
        }
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
        if pickerView == genderPicker {
            return genders.count
        } else if pickerView == bikePicker {
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
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.adjustsFontSizeToFitWidth = true
        pickerLabel.minimumScaleFactor = 0.5
        pickerLabel.textAlignment = .center
        var title = ""
        if pickerView == genderPicker {
            title = genders[row]
        } else if pickerView == bikePicker {
            title = bikes[row]
        } else if pickerView == approximateMilePicker {
            title = String(approximateMiles[row])
        } else if pickerView == penaltyTypePicker {
            title = penaltyTypes[row].name
        } else if pickerView == bikeLengthsPicker {
            title = bikeLengths[row]
        } else if pickerView == secondsPicker {
            title = seconds[row]
        } else {
            if currentTextField == bikeColorTextField {
                colors[0] = "Bike Color"
            } else if currentTextField == helmetColorTextField {
                colors[0] = "Helmet Color"
            } else if currentTextField == topColorTextField {
                colors[0] = "Top Color"
            } else if currentTextField == pantColorTextField {
                colors[0] = "Pant Color"
            }
            title = colors[row]
        }
        var myTitle: NSAttributedString!
        if row == 0 {
            myTitle = NSAttributedString(string: title, attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 32.0),NSForegroundColorAttributeName: UIColor.black])
        } else {
            myTitle = NSAttributedString(string: title, attributes: [NSFontAttributeName:UIFont.systemFont(ofSize: 32.0),NSForegroundColorAttributeName: UIColor.black])
        }
        pickerLabel.attributedText = myTitle
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            currentTextField?.text = ""
            return
        }
        if pickerView == genderPicker {
            currentTextField?.text = genders[row]
        } else if pickerView == bikePicker {
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
        
        if penalty != nil {
            confirmPenaltyDetails()
        } else {
            confirmBibNumber()
        }
        
    }
    
    func confirmBibNumber() {
        let alert = UIAlertController(title: "Confirm Bib Number", message: "Enter the Bib Number again to confirm.", preferredStyle: .alert)
        
        let submitAction = UIAlertAction(title: "OK", style: .default) { (_) in
            if let field = alert.textFields?[0] {
                if field.text == self.bibNumberTextField.text {
                    self.confirmPenaltyDetails()
                } else {
                    self.displayAlert(title: "Bib Numbers Don't Match", message: "Make sure the bib number matches the one entered earlier and try again.")
                }
            }
        }
                
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Bib Number"
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.frame.size.height = 50.0
            textField.font = textField.font?.withSize(20.0)
        }
        
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func confirmPenaltyDetails() {
        
        let bibNumber = bibNumberTextField.text!
        let gender = genderTextField.text!
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
        var existingEdits = ["":""]
        if let existingPenalty = self.penalty {
            existingPenaltyUid = existingPenalty.uid
            existingEdits = existingPenalty.edits
        }
        
        var newPenalty = Penalty(uid: existingPenaltyUid, bibNumber: bibNumber, gender: gender, bikeType: bikeType, bikeColor: bikeColor, helmetColor: helmetColor, topColor: topColor, pantColor: pantColor, penalty: penalty, bikeLengths: bikeLengths, seconds: seconds, approximateMile: approximateMile, notes: notes, submittedBy: submittedBy!, timeStamp: "", checkedIn: false, edited: false, edits: [:])
        
        if let existingPenalty = self.penalty {
            if existingPenalty == newPenalty {
                displayAlert(title: "No changes made.", message: "There are no changes to submit.")
                return
            }
        }
        
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
                newPenalty.timeStamp = GlobalFunctions.shared.getCurrentDateAndTime()
                newPenalty.edits = [newPenalty.timeStamp:submittedBy!]
            } else {
                newPenalty.timeStamp = (self.penalty?.timeStamp)!
                existingEdits[GlobalFunctions.shared.getCurrentDateAndTime()] = submittedBy
                newPenalty.edits = existingEdits
                newPenalty.edited = true
            }
            if GlobalFunctions.shared.hasConnectivity() {
                FirebaseClient.shared.postPenalty(eventID: (self.eventID)!, penaltyID: existingPenaltyUid, penalty: newPenalty) { (success, message) -> () in
                    if let success = success, let message = message {
                        if success {
                            let alert = UIAlertController(title: "Success!", message: message as String, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                                if existingPenaltyUid == "" {
                                    self.navigationController?.popViewController(animated: true)
                                } else {
                                    self.updateEditsArray(existingEdits: existingEdits)
                                    self.editsTableView.reloadData()
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

extension LogPenaltyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return edits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editCell")!
        if indexPath.row == 0 {
            cell.textLabel?.text = "Issued by \(String(describing: edits[indexPath.row].name))"
        } else {
            cell.textLabel?.text = "Edited by \(String(describing: edits[indexPath.row].name))"
        }
        cell.detailTextLabel?.text = GlobalFunctions.shared.formattedTimestamp(ts: edits[indexPath.row].timeStamp, includeDate: true, includeTime: true)
        return cell
    }
    
    func updateEditsArray(existingEdits: [String:String]) {
        edits = []
        for (key, value) in existingEdits {
            let newEdit = Edit(name: value as String, timeStamp: key as String)
            self.edits.append(newEdit)
        }
        edits.sort { $0.timeStamp < $1.timeStamp }
    }
    
}
