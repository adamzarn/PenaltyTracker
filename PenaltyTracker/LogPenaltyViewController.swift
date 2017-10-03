//
//  LogPenaltyViewController.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/6/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class LogPenaltyViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var location: CLLocation! {
        didSet {
            myMapView.centerCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            dropPin(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        }
    }

    func checkCoreLocationPermission() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            checkCoreLocationPermission()
        } else if CLLocationManager.authorizationStatus() == .restricted {
            print("Unauthorized to use location service")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        locationManager.stopUpdatingLocation()
    }

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var eventID: String?
    var penalty: Penalty?
    var navBarHeight: CGFloat!
    var edits: [Edit] = []
    var options: [String] = []

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var selectionTableView: UITableView!
    @IBOutlet weak var aiv: UIActivityIndicatorView!

    @IBOutlet weak var bibNumberTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!

    @IBOutlet weak var appearanceLabel: UILabel!

    @IBOutlet weak var profilePhoto: UIImageView!
    
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

    @IBOutlet weak var locationLabel: UILabel!

    @IBOutlet weak var myMapView: MKMapView!

    @IBOutlet weak var notesLabel: UILabel!

    @IBOutlet weak var notesTextView: UITextView!

    @IBOutlet weak var editsLabel: UILabel!
    @IBOutlet weak var editsTableView: UITableView!

    @IBOutlet weak var submitButton: UIBarButtonItem!

    @IBOutlet weak var toolbar: UIToolbar!
    var doneToolbar: UIToolbar!

    var bikes: [String] = []

    var colors: [String] = []

    var penaltyNames: [String] = []
    var penaltyTypes: [PenaltyType] = []

    let bikeLengths = ["(Blank)","1","2","3","4","5"]

    var seconds = ["(Blank)","26","27","28","29","30","31","32","33","34","35","36","37","38",
                   "39","40","41","42","43","44","45","46","47","48","49","50","51",
                   "52","53","54","55","56","57","58","59","60+"]

    let approximateMiles = ["(Blank)","1","2","3","4","5","6","7","8","9","10",
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

    var currentTextField: UITextField?
    var pendingCurrentTextField: UITextField?
    var dimView: UIView?

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
                    self.bikes.insert("(Blank)", at: 0)
                    self.colors = colors
                    self.colors.insert("(Blank)", at: 0)
                    self.penaltyTypes = penaltyTypes
                    self.penaltyTypes.insert(PenaltyType(name: "(Blank)", color: ""), at: 0)
                    
                    for penaltyType in self.penaltyTypes {
                        self.penaltyNames.append(penaltyType.name)
                    }
                    
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
        locationLabel.textColor = appDelegate.darkBlueColor

        submitButton.tintColor = appDelegate.darkBlueColor
        
        dimView = UIView(frame: UIScreen.main.bounds)
        dimView?.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        selectionView.isHidden = true
        selectionView.isUserInteractionEnabled = false
        
        profilePhoto.layer.cornerRadius = 4
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.borderColor = UIColor.lightGray.cgColor

    }
    
    func showPopup() {
        self.view.addSubview(dimView!)
        self.view.bringSubview(toFront: dimView!)
        selectionView.isHidden = false
        selectionView.isUserInteractionEnabled = true
        self.view.bringSubview(toFront: selectionView)
    }
    
    func dismissPopup() {
        self.dimView?.removeFromSuperview()
        selectionView.isHidden = true
        selectionView.isUserInteractionEnabled = false
        selectionTableView.setContentOffset(CGPoint.zero, animated: false)
        currentTextField?.resignFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)

        myMapView.region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        if let penalty = penalty {
            if penalty.lat != "" {
                myMapView.centerCoordinate = CLLocationCoordinate2D(latitude: Double(penalty.lat)!, longitude: Double(penalty.long)!)
                dropPin(lat: Double(penalty.lat)!, long: Double(penalty.long)!)
            }
        } else {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkCoreLocationPermission()
        }

    }

    override func viewWillAppear(_ animated: Bool) {

        //NotificationCenter.default.addObserver(self, selector: #selector(LogPenaltyViewController.orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.contentView.frame.size.height)

        scrollView.isScrollEnabled = true

        myMapView.removeAnnotations(myMapView.annotations)

        if penalty != nil {
            self.title = "Review Penalty"
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        //NotificationCenter.default.removeObserver(NSNotification.Name.UIDeviceOrientationDidChange)
    }

    func dropPin(lat: Double, long: Double) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        myMapView.addAnnotation(annotation)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.animatesDrop = true
        }

        return pinView
    }

    func setUpTextFields() {
    
        genderTextField.inputView = UIView()
        bikeTypeTextField.inputView = UIView()
        bikeColorTextField.inputView = UIView()
        helmetColorTextField.inputView = UIView()
        topColorTextField.inputView = UIView()
        pantColorTextField.inputView = UIView()
        penaltyTextField.inputView = UIView()
        bikeLengthsTextField.inputView = UIView()
        secondsTextField.inputView = UIView()
        approximateMileTextField.inputView = UIView()
    
        doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
        doneToolbar.barStyle = .default
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))

        doneToolbar.items = [flex, done]

        bibNumberTextField.inputAccessoryView = doneToolbar

        notesTextView.inputAccessoryView = doneToolbar

    }
    
    func dismissKeyboard() {
        if currentTextField == bibNumberTextField {
            confirmBibNumber()
        }
        notesTextView.resignFirstResponder()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if currentTextField == bibNumberTextField && textField != bibNumberTextField {
            pendingCurrentTextField = textField
            confirmBibNumber()
        } else {
            currentTextField = textField
            textField.becomeFirstResponder()
            if textField != bibNumberTextField {
                switch textField {
                    case genderTextField: options = ["(Blank)", "Male", "Female"]
                    categoryLabel.text = "Gender"
                    case bikeTypeTextField: options = bikes
                    categoryLabel.text = "Bike Type"
                    case bikeColorTextField: options = colors
                    categoryLabel.text = "Bike Color"
                    case helmetColorTextField: options = colors
                    categoryLabel.text = "Helmet Color"
                    case topColorTextField: options = colors
                    categoryLabel.text = "Top Color"
                    case pantColorTextField: options = colors
                    categoryLabel.text = "Pant Color"
                    case penaltyTextField: options = penaltyNames
                    categoryLabel.text = "Penalty"
                    case bikeLengthsTextField: options = bikeLengths
                    categoryLabel.text = "Bike Lengths"
                    case secondsTextField: options = seconds
                    categoryLabel.text = "Seconds"
                    case approximateMileTextField: options = approximateMiles
                    categoryLabel.text = "Approximate Mile"
                    default: options = []
                }
                selectionTableView.reloadData()
                showPopup()
            }
        }
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == bibNumberTextField {
            confirmBibNumber()
        }
        textField.resignFirstResponder()
        return true
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

        confirmPenaltyDetails()

    }

    func confirmBibNumber() {
        
        if bibNumberTextField.text != "" {
        
            currentTextField = nil
            let alert = UIAlertController(title: "Confirm Bib Number", message: "Enter the Bib Number again to confirm.", preferredStyle: .alert)

            let submitAction = UIAlertAction(title: "OK", style: .default) { (_) in
                if let field = alert.textFields?[0] {
                    if field.text != self.bibNumberTextField.text {
                        self.bibNumberTextField.text = ""
                        self.displayAlert(title: "Bib Numbers Don't Match", message: "Make sure the bib number matches the one entered earlier and try again.")
                    } else {
                        self.currentTextField?.resignFirstResponder()
                        self.currentTextField = nil
                        if let pendingCurrentTextField = self.pendingCurrentTextField {
                            self.currentTextField = pendingCurrentTextField
                            self.pendingCurrentTextField = nil
                            self.currentTextField?.becomeFirstResponder()
                        }
                    }
                }
            }

            alert.addTextField { (textField) in
                textField.placeholder = "Bib Number"
                textField.textAlignment = .center
                textField.keyboardType = .numberPad
                textField.frame.size.height = 50.0
                textField.font = textField.font?.withSize(20.0)
            }

            alert.addAction(submitAction)

            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            self.currentTextField?.resignFirstResponder()
            self.currentTextField = nil
            
        }
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

        var newPenalty = Penalty(uid: existingPenaltyUid, bibNumber: bibNumber, gender: gender, bikeType: bikeType, bikeColor: bikeColor, helmetColor: helmetColor, topColor: topColor, pantColor: pantColor, penalty: penalty, bikeLengths: bikeLengths, seconds: seconds, approximateMile: approximateMile, notes: notes, submittedBy: submittedBy!, timeStamp: "", checkedIn: false, edited: false, edits: [:], lat: String(location.coordinate.latitude), long: String(location.coordinate.longitude))

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

    @IBAction func recenterButtonPressed(_ sender: Any) {
        if let penalty = penalty {
            myMapView.centerCoordinate = CLLocationCoordinate2D(latitude: Double(penalty.lat)!, longitude: Double(penalty.long)!)
        } else {
            myMapView.centerCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }


}

extension LogPenaltyViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == selectionTableView {
            return options.count
        } else {
            return edits.count
        }
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == editsTableView {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "editCell")!
            if indexPath.row == 0 {
                cell.textLabel?.text = "Issued by \(String(describing: edits[indexPath.row].name))"
            } else {
                cell.textLabel?.text = "Edited by \(String(describing: edits[indexPath.row].name))"
            }
            cell.detailTextLabel?.text = GlobalFunctions.shared.formattedTimestamp(ts: edits[indexPath.row].timeStamp, includeDate: true, includeTime: true)
            return cell
            
        } else {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
            
            if options[indexPath.row] == "(Blank)" {
                cell.textLabel?.attributedText = GlobalFunctions.shared.italic(string: "(Blank)", size: 17.0, color: .lightGray)
            } else {
                cell.textLabel?.text = options[indexPath.row]
            }
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == selectionTableView {
            if currentTextField == penaltyTextField {
                
                if penaltyTypes[indexPath.row].name == "Drafting" {
                    bikeLengthsTextField.isEnabled = true
                    secondsTextField.isEnabled = true
                } else {
                    bikeLengthsTextField.isEnabled = false
                    bikeLengthsTextField.text = ""
                    secondsTextField.isEnabled = false
                    secondsTextField.text = ""
                }
                
                if penaltyTypes[indexPath.row].color == "Blue" {
                    cardView.backgroundColor = appDelegate.darkBlueColor
                    cardLabel.text = "Blue Card"
                    cardLabel.textColor = .white
                } else if penaltyTypes[indexPath.row].color == "Yellow" {
                    cardView.backgroundColor = appDelegate.yellowColor
                    cardLabel.text = "Yellow Card"
                    cardLabel.textColor = .black
                } else {
                    cardView.backgroundColor = .white
                    cardLabel.text = "Card"
                    cardLabel.textColor = .black
                }
                
            }
            
            if currentTextField == genderTextField {
                if options[indexPath.row] == "Female" {
                    profilePhoto.image = UIImage(named: "Girl.png")
                } else {
                    profilePhoto.image = UIImage(named: "Boy.png")
                }
            }
            
            if options[indexPath.row] == "(Blank)" {
                currentTextField?.text = ""
            } else {
                currentTextField?.text = options[indexPath.row]
            }
            
            dismissPopup()
            
        }
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
