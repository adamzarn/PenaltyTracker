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
import Darwin
import AVKit
import AVFoundation
import MobileCoreServices

class LogPenaltyViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVAudioRecorderDelegate {
    
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
        var distanceTraveled: Double?
        if let plottedLocation = location, let newLocation = locations.last {
            let lat1 = plottedLocation.coordinate.latitude as Double
            let long1 = plottedLocation.coordinate.longitude as Double
            let lat2 = newLocation.coordinate.latitude as Double
            let long2 = newLocation.coordinate.longitude as Double
            let latDelta = lat2-lat1
            let longDelta = long2-long1
            distanceTraveled = sqrt(pow(latDelta, 2) + pow(longDelta, 2))
            if let distanceTraveled = distanceTraveled {
                if distanceTraveled > 0.0001 {
                    location = locations.last
                    dropPin(lat: location.coordinate.latitude, long: location.coordinate.longitude)
                }
            }
        } else {
            location = locations.last
            dropPin(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var eventID: String?
    var penalty: Penalty?
    var navBarHeight: CGFloat!
    var edits: [Edit] = []
    var options: [String] = []
    var profilePhotoImageData: Data?
    var videoData: Data?
    var videoUrl: URL?
    var audioData: Data?
    var audioUrl: URL?
    var appearingAfterImagePicker = false
    var shouldUploadPhoto = false
    var shouldUploadVideo = false
    var shouldUploadAudio = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var selectionTableView: UITableView!
    
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    @IBOutlet weak var uploadingLabel: UILabel!
    
    @IBOutlet weak var photoAiv: UIActivityIndicatorView!
    @IBOutlet weak var videoAiv: UIActivityIndicatorView!
    
    @IBOutlet weak var bibNumberTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!

    @IBOutlet weak var appearanceLabel: UILabel!

    @IBOutlet weak var profilePhoto: UIButton!
    
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
    
    @IBOutlet weak var mediaLabel: UILabel!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var noVideoToPlayLabel: UILabel!
    var player: AVPlayer!
    var superLayer: CALayer!
    var playerLayer: AVPlayerLayer!
    @IBOutlet weak var uploadVideoButton: UIButton!
    @IBOutlet weak var videoControls: UIToolbar!
    
    @IBOutlet weak var recordAudioButton: UIButton!
    @IBOutlet weak var recordAudioImageButton: UIButton!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var audioEngine: AVAudioEngine!
    var session: AVAudioSession!
    @IBOutlet weak var savedRecordingButton: UIButton!
    var currentAudioDuration: Double?
    
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

        cardView.layer.borderWidth = 0.25
        cardView.layer.borderColor = UIColor.lightGray.cgColor
        cardView.layer.cornerRadius = 5.00

        notesTextView.layer.borderWidth = 0.25
        notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        notesTextView.layer.cornerRadius = 5.00
        
        myMapView.layer.cornerRadius = 5.00
        
        if GlobalFunctions.shared.hasConnectivity() {
            FirebaseClient.shared.getDescriptors() { (bikes, colors, penaltyTypes, error) -> () in
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
        
        appearanceLabel.textColor = appDelegate.darkBlueColor
        penaltyLabel.textColor = appDelegate.darkBlueColor
        notesLabel.textColor = appDelegate.darkBlueColor
        editsLabel.textColor = appDelegate.darkBlueColor
        locationLabel.textColor = appDelegate.darkBlueColor
        mediaLabel.textColor = appDelegate.darkBlueColor
        
        submitButton.tintColor = appDelegate.darkBlueColor
        
        dimView = UIView(frame: UIScreen.main.bounds)
        dimView?.backgroundColor = UIColor(white: 0.4, alpha: 0.8)
        selectionView.isHidden = true
        selectionView.isUserInteractionEnabled = false
        
        profilePhoto.layer.cornerRadius = 5.0
        profilePhoto.layer.borderWidth = 0.25
        profilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        profilePhoto.imageView?.layer.cornerRadius = 5.0
        profilePhoto.imageView?.contentMode = .scaleAspectFill
        
        playerView.layer.borderWidth = 0.25
        playerView.layer.borderColor = UIColor.lightGray.cgColor
        roundTopsOf(view: playerView)
        roundBottomsOf(view: videoControls)
        
        player = AVPlayer()
        superLayer = self.playerView.layer
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.playerView.bounds
        playerLayer.cornerRadius = 5.0
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        superLayer.addSublayer(playerLayer)

        self.photoAiv.isHidden = true
        self.view.bringSubview(toFront: photoAiv)
        
        roundBottomsOf(view: savedRecordingButton)
        session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayback)
        
    }
    
    @IBAction func uploadVideoButtonPressed(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String]
        self.present(picker, animated: true, completion: nil)
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
    
    func populateView(penalty: Penalty) {
        
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
        
        self.profilePhoto.setImage(UIImage(data: Data()), for: .normal)
        self.photoAiv.isHidden = false
        self.photoAiv.startAnimating()
        FirebaseClient.shared.getProfilePhoto(eventID: eventID!, penaltyID: penalty.uid) { (image) -> () in
            self.photoAiv.isHidden = true
            self.photoAiv.stopAnimating()
            if let image = image {
                self.profilePhoto.setImage(image, for: .normal)
            } else {
                if self.genderTextField.text == "Female" {
                    self.profilePhoto.setImage(UIImage(named: "Girl.png"), for: .normal)
                } else {
                    self.profilePhoto.setImage(UIImage(named: "Boy.png"), for: .normal)
                }
            }
        }
        
        videoAiv.isHidden = false
        videoAiv.startAnimating()
        FirebaseClient.shared.getVideo(eventID: eventID!, penaltyID: penalty.uid) { (video, error) -> () in
            self.videoAiv.isHidden = true
            self.videoAiv.stopAnimating()
            if let video = video {
                let currentVideoUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("currentVideo.mp4")
                do {
                    try video.write(to: currentVideoUrl, options: .atomic)
                    let item = AVPlayerItem(url: currentVideoUrl)
                    self.player.replaceCurrentItem(with: item)
                    self.noVideoToPlayLabel.isHidden = true
                } catch {
                    print("Couldn't write video to file")
                    self.noVideoToPlayLabel.isHidden = false
                }
            } else {
                print("The error is \(error?.localizedDescription ?? "Error")")
                self.noVideoToPlayLabel.isHidden = false
            }
        }
        
        savedRecordingButton.setTitle("CHECKING FOR SAVED RECORDING...", for: .normal)
        savedRecordingButton.isEnabled = false
        savedRecordingButton.backgroundColor = self.appDelegate.darkBlueColor.withAlphaComponent(0.5)
        FirebaseClient.shared.getAudio(eventID: eventID!, penaltyID: penalty.uid) { (audio, error) -> () in
            if let audio = audio {
                let currentAudioUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("currentAudio.wav")
                do {
                    try audio.write(to: currentAudioUrl, options: .atomic)
                    self.audioPlayer =  try! AVAudioPlayer(contentsOf: currentAudioUrl)
                    self.audioPlayer.enableRate = true
                    self.currentAudioDuration = self.audioPlayer.duration
                    self.audioEngine = AVAudioEngine()
                    let duration = GlobalFunctions.shared.convertDoubleToTime(duration: self.currentAudioDuration!)
                    self.savedRecordingButton.setTitle("PLAY SAVED RECORDING (\(duration))", for: .normal)
                    self.savedRecordingButton.isEnabled = true
                    self.savedRecordingButton.backgroundColor = self.appDelegate.darkBlueColor
                } catch {
                    print("Couldn't write video to file")
                }
            } else {
                print("The error is \(error?.localizedDescription ?? "Error")")
                self.savedRecordingButton.setTitle("NO RECORDING SAVED", for: .normal)
                self.savedRecordingButton.isEnabled = false
                self.savedRecordingButton.backgroundColor = self.appDelegate.darkBlueColor.withAlphaComponent(0.5)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        noVideoToPlayLabel.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(LogPenaltyViewController.orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LogPenaltyViewController.playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)

        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.contentView.frame.size.height)

        scrollView.isScrollEnabled = true
        
        myMapView.removeAnnotations(myMapView.annotations)
        
        if appearingAfterImagePicker {
            if let location = location {
                dropPin(lat: location.coordinate.latitude, long: location.coordinate.longitude)
            }
            appearingAfterImagePicker = false
        } else {
            shouldUploadPhoto = false
            shouldUploadVideo = false
            shouldUploadAudio = false
            if let penalty = penalty {
                self.title = "Review Penalty"
                populateView(penalty: penalty)
            } else {
                if self.genderTextField.text == "Female" {
                    self.profilePhoto.setImage(UIImage(named: "Girl.png"), for: .normal)
                } else {
                    self.profilePhoto.setImage(UIImage(named: "Boy.png"), for: .normal)
                }
            }
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(NSNotification.Name.UIDeviceOrientationDidChange)
        NotificationCenter.default.removeObserver(NSNotification.Name.AVPlayerItemDidPlayToEndTime)
    }
    
    func playerDidFinishPlaying() {
        player.seek(to: kCMTimeZero)
    }
    
    func orientationChanged() {
        
        videoControls.layer.mask = nil
        savedRecordingButton.layer.mask = nil
        
        playerView.layer.mask = nil
        
        roundBottomsOf(view: videoControls)
        roundBottomsOf(view: savedRecordingButton)
        
        roundTopsOf(view: playerView)
        
        if UIDevice.current.orientation.isLandscape {
            self.contentViewHeight.constant = 2400
            
        } else {
            self.contentViewHeight.constant = 2100
        }
        playerLayer.frame = self.playerView.bounds
    }

    func dropPin(lat: Double, long: Double) {
        myMapView.removeAnnotations(myMapView.annotations)
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
        let penaltyString = penaltyTextField.text!
        let bikeLengths = bikeLengthsTextField.text!
        let seconds = secondsTextField.text!
        let approximateMile = approximateMileTextField.text!
        let submittedBy = appDelegate.currentUser?.name
        let notes = notesTextView.text!
        var existingPenaltyUid = ""
        var existingEdits = ["":""]
        var lat = ""
        var long = ""
        var checkedIn = false
        if let existingPenalty = self.penalty {
            existingPenaltyUid = existingPenalty.uid
            existingEdits = existingPenalty.edits
            lat = existingPenalty.lat
            long = existingPenalty.long
            checkedIn = existingPenalty.checkedIn
        } else {
            lat = String(location.coordinate.latitude)
            long = String(location.coordinate.longitude)
        }

        var newPenalty = Penalty(uid: existingPenaltyUid, bibNumber: bibNumber, gender: gender, bikeType: bikeType, bikeColor: bikeColor, helmetColor: helmetColor, topColor: topColor, pantColor: pantColor, penalty: penaltyString, bikeLengths: bikeLengths, seconds: seconds, approximateMile: approximateMile, notes: notes, submittedBy: submittedBy!, timeStamp: "", checkedIn: checkedIn, edited: false, edits: [:], lat: lat, long: long)

        if let existingPenalty = self.penalty {
            if existingPenalty == newPenalty && !shouldUploadPhoto && !shouldUploadVideo && !shouldUploadAudio {
                displayAlert(title: "No changes made.", message: "There are no changes to submit.")
                return
            } else {
                var tasks: [String] = []
                if existingPenalty != newPenalty {
                    tasks.append("penalty details")
                }
                if shouldUploadPhoto {
                    tasks.append("a photo")
                }
                if shouldUploadVideo {
                    tasks.append("a video")
                }
                if shouldUploadAudio {
                    tasks.append("a voice recording")
                }
                if tasks.count == 1 {
                    uploadingLabel.text = "Uploading \(tasks[0])..."
                } else if tasks.count == 2 {
                    uploadingLabel.text = "Uploading \(tasks[0]) and \(tasks[1])..."
                } else if tasks.count == 3 {
                    uploadingLabel.text = "Uploading \(tasks[0]), \(tasks[1]), and \(tasks[2])..."
                } else if tasks.count == 4 {
                    uploadingLabel.text = "Uploading \(tasks[0]), \(tasks[1]), \(tasks[2]), and \(tasks[3])..."
                } else {
                    uploadingLabel.text = "Uploading..."
                }
            }
        }

        var penaltyMessage = ""
        if penaltyString == "Drafting" {
            if bikeLengths == "1" {
                penaltyMessage = "\(penaltyString) (\(bikeLengths) length, \(seconds) s)"
            } else {
                penaltyMessage = "\(penaltyString) (\(bikeLengths) lengths, \(seconds) s)"
            }
        } else {
            penaltyMessage = penaltyString
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
                self.aiv.isHidden = false
                self.aiv.startAnimating()
                self.uploadingLabel.isHidden = false
                self.view.addSubview(self.dimView!)
                self.view.bringSubview(toFront: self.dimView!)
                self.view.bringSubview(toFront: self.aiv)
                self.view.bringSubview(toFront: self.uploadingLabel)
                var profilePhoto: Data!
                if let p = self.profilePhotoImageData {
                    profilePhoto = p
                } else {
                    profilePhoto = Data()
                }
                var videoData: Data!
                if let v = self.videoData {
                    videoData = v
                } else {
                    videoData = Data()
                }
                var audioData: Data!
                if let a = self.audioData {
                    audioData = a
                } else {
                    audioData = Data()
                }
                FirebaseClient.shared.postPenalty(eventID: (self.eventID)!, penaltyID: existingPenaltyUid, penalty: newPenalty, imageData: profilePhoto, shouldUploadPhoto: self.shouldUploadPhoto, videoData: videoData, shouldUploadVideo: self.shouldUploadVideo, audioData: audioData, shouldUploadAudio: self.shouldUploadAudio) { (success, message) -> () in
                    self.shouldUploadPhoto = false
                    self.shouldUploadVideo = false
                    self.shouldUploadAudio = false
                    self.aiv.isHidden = true
                    self.aiv.stopAnimating()
                    self.uploadingLabel.isHidden = true
                    self.dimView?.removeFromSuperview()
                    if let success = success, let message = message {
                        if success {
                            let alert = UIAlertController(title: "Success!", message: message as String, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
                                if existingPenaltyUid == "" {
                                    self.navigationController?.popViewController(animated: true)
                                } else {
                                    self.updateEditsArray(existingEdits: existingEdits)
                                    self.editsTableView.reloadData()
                                    self.penalty = newPenalty
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
            if (range.length + range.location > currentCharacterCount) {
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
    
    @IBAction func addProfilePhoto(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        let sourceTypeAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sourceTypeAlert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
            picker.sourceType = UIImagePickerControllerSourceType.camera
            self.present(picker, animated: true, completion: nil)
        }))
        sourceTypeAlert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { (action) in
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(picker, animated: true, completion: nil)
        }))
        if profilePhotoImageData != nil {
            sourceTypeAlert.addAction(UIAlertAction(title: "Remove Current Photo", style: .default, handler: { (action) in
                self.profilePhotoImageData = nil
                if self.genderTextField.text == "Female" {
                    self.profilePhoto.setImage(UIImage(named: "Girl.png"), for: .normal)
                } else {
                    self.profilePhoto.setImage(UIImage(named: "Boy.png"), for: .normal)
                }
            }))
        }
        
        self.present(sourceTypeAlert, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        appearingAfterImagePicker = true
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        appearingAfterImagePicker = true
        picker.dismiss(animated: true, completion: nil)
        
        let mediaType = info[UIImagePickerControllerMediaType] as! CFString
        let isMovie = UTTypeConformsTo(mediaType as CFString, kUTTypeMovie)
        
        if isMovie {
            let videoUrl = info[UIImagePickerControllerMediaURL] as? URL
            
            if let videoUrl = videoUrl {
                do {
                    videoData = try Data(contentsOf: videoUrl)
                    shouldUploadVideo = true
                    let item = AVPlayerItem(url: videoUrl)
                    self.player.replaceCurrentItem(with: item)
                } catch {
                    print(error.localizedDescription)
                }
            }
            
        } else {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            profilePhotoImageData = UIImageJPEGRepresentation(image, 0.0)
            shouldUploadPhoto = true
            profilePhoto.setImage(UIImage(data: profilePhotoImageData!), for: .normal)
        }
        
    }
    
    @IBAction func playVideoButtonPressed(_ sender: Any) {
        player.play()
    }
    
    @IBAction func pauseVideoButtonPressed(_ sender: Any) {
        player.pause()
    }
    
    @IBAction func startOverButtonPressed(_ sender: Any) {
        player.pause()
        player.seek(to: kCMTimeZero)
    }
    
    @IBAction func recordAudioButtonPressed(_ sender: Any) {
        
        if recordAudioButton.titleLabel?.text == "RECORD AUDIO" {
        
            recordAudioButton.setTitle("STOP RECORDING", for: .normal)
            savedRecordingButton.setTitle("RECORDING...", for: .normal)
            savedRecordingButton.isEnabled = false
            self.savedRecordingButton.backgroundColor = self.appDelegate.darkBlueColor.withAlphaComponent(0.5)
            audioUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("currentAudio.wav")
            try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try! audioRecorder = AVAudioRecorder(url: audioUrl!, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            
        } else {
            
            recordAudioButton.setTitle("RECORD AUDIO", for: .normal)
            audioRecorder.stop()
            try! session.setActive(false)
            
        }
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag) {
            if let audioUrl = audioUrl {
                do {
                    audioData = try Data(contentsOf: audioUrl)
                    shouldUploadAudio = true
                    self.audioPlayer =  try! AVAudioPlayer(contentsOf: audioUrl)
                    self.audioPlayer.enableRate = true
                    self.audioEngine = AVAudioEngine()
                    self.currentAudioDuration = self.audioPlayer.duration
                    let duration = GlobalFunctions.shared.convertDoubleToTime(duration: self.currentAudioDuration!)
                    self.savedRecordingButton.setTitle("PLAY SAVED RECORDING (\(duration))", for: .normal)
                    self.savedRecordingButton.isEnabled = true
                    self.savedRecordingButton.backgroundColor = self.appDelegate.darkBlueColor
                } catch {
                    print("could not save audio")
                }
            }
        } else {
            print("saving failed")
        }
    }
    
    func stopAllAudio() {
        audioEngine.stop()
        audioEngine.reset()
        audioPlayer.stop()
        audioPlayer.currentTime = 0.0
    }
    
    @IBAction func playRecording(_ sender: Any) {
        try! session.setCategory(AVAudioSessionCategoryPlayback)
        audioPlayer.play()
    }
    
    func roundBottomsOf(view: UIView) {
        
        let maskPath = UIBezierPath.init(roundedRect: view.bounds, byRoundingCorners:[.bottomLeft, .bottomRight], cornerRadii: CGSize.init(width: 5.0, height: 5.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer

    }
    
    func roundTopsOf(view: UIView) {
        
        let maskPath = UIBezierPath.init(roundedRect: view.bounds, byRoundingCorners:[.topLeft, .topRight], cornerRadii: CGSize.init(width: 5.0, height: 5.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
        
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
                if profilePhotoImageData == nil {
                    if options[indexPath.row] == "Female" {
                        profilePhoto.setImage(UIImage(named: "Girl.png"), for: .normal)
                    } else {
                        profilePhoto.setImage(UIImage(named: "Boy.png"), for: .normal)
                    }
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
