//
//  CustomObjects.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/4/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import Foundation
import JTAppleCalendar

struct User {
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func toAnyObject() -> AnyObject {
        return ["name": name] as AnyObject
    }
    
}

struct Event: Equatable {
    
    let uid: String
    let name: String
    let pin: String
    let city: String
    let state: String
    let date: String
    let createdDate: String
    let admin: String
    let adminName: String
    
    init(uid: String, name: String, pin: String, city: String, state: String, date: String, createdDate: String, admin: String, adminName: String) {
        self.uid = uid
        self.name = name
        self.pin = pin
        self.city = city
        self.state = state
        self.date = date
        self.createdDate = createdDate
        self.admin = admin
        self.adminName = adminName
    }
    
    func toAnyObject() -> AnyObject {
        return ["name": name,
                "pin": pin,
                "city": city,
                "state": state,
                "date": date,
                "createdDate": createdDate,
                "admin": admin,
                "adminName": adminName] as AnyObject
    }
    
    public static func ==(old: Event, new: Event) -> Bool {
        return
            old.name == new.name &&
                old.city == new.city &&
                old.state == new.state &&
                old.date == new.date &&
                old.pin == new.pin
    }
    
}

struct PenaltyType {
    
    let name: String
    let color: String
    
    init(name: String, color: String) {
        self.name = name
        self.color = color
    }
    
}

struct Penalty: Equatable {
    
    let uid: String
    let bibNumber: String
    let gender: String
    let bikeType: String
    let bikeColor: String
    let helmetColor: String
    let topColor: String
    let pantColor: String
    let penalty: String
    let bikeLengths: String
    let seconds: String
    let approximateMile: String
    let notes: String
    let submittedBy: String
    var timeStamp: String
    var checkedIn: Bool
    var edited: Bool
    var edits: [String: String]
    var lat: String
    var long: String
    
    init(uid: String, bibNumber: String, gender: String, bikeType: String, bikeColor: String, helmetColor: String, topColor: String, pantColor: String, penalty: String, bikeLengths: String, seconds: String, approximateMile: String, notes: String, submittedBy: String, timeStamp: String, checkedIn: Bool, edited: Bool, edits: [String: String], lat: String, long: String) {
        self.uid = uid
        self.bibNumber = bibNumber
        self.gender = gender
        self.bikeType = bikeType
        self.bikeColor = bikeColor
        self.helmetColor = helmetColor
        self.topColor = topColor
        self.pantColor = pantColor
        self.penalty = penalty
        self.bikeLengths = bikeLengths
        self.seconds = seconds
        self.approximateMile = approximateMile
        self.notes = notes
        self.submittedBy = submittedBy
        self.timeStamp = timeStamp
        self.checkedIn = checkedIn
        self.edited = edited
        self.edits = edits
        self.lat = lat
        self.long = long
    }
    
    func toAnyObject() -> AnyObject {
        return ["bibNumber": bibNumber,
                "gender": gender,
                "bikeType": bikeType,
                "bikeColor": bikeColor,
                "helmetColor": helmetColor,
                "topColor": topColor,
                "pantColor": pantColor,
                "penalty": penalty,
                "bikeLengths": bikeLengths,
                "seconds": seconds,
                "approximateMile": approximateMile,
                "notes": notes,
                "submittedBy": submittedBy,
                "timeStamp": timeStamp,
                "checkedIn": false,
                "edited": edited,
                "edits": edits,
                "lat": lat,
                "long": long] as AnyObject
    }
    
    public static func ==(old: Penalty, new: Penalty) -> Bool {
        return
            old.bibNumber == new.bibNumber &&
            old.gender == new.gender &&
            old.bikeType == new.bikeType &&
            old.bikeColor == new.bikeColor &&
            old.helmetColor == new.helmetColor &&
            old.topColor == new.topColor &&
            old.pantColor == new.pantColor &&
            old.penalty == new.penalty &&
            old.bikeLengths == new.bikeLengths &&
            old.seconds == new.seconds &&
            old.approximateMile == new.approximateMile &&
            old.notes == new.notes
    }
    
}

class CalendarCell: JTAppleCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    
}

class MyNavigationController: UINavigationController, UIViewControllerTransitioningDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.barTintColor = appDelegate.darkBlueColor
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
}

class EventCell: UITableViewCell {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    
    func setUpCell(event: Event) {
        
        eventNameLabel.attributedText = GlobalFunctions.shared.bold(string: event.name, size: 16.0, color: .black)
        
        locationLabel.attributedText = GlobalFunctions.shared.italic(string: event.city + ", " + event.state, size: 16.0, color: .black)
        
        let formattedDate = GlobalFunctions.shared.formattedTimestamp(ts: event.date, includeDate: true, includeTime: false)
        dateLabel.attributedText = GlobalFunctions.shared.bold(string: formattedDate, size: 16.0, color: appDelegate.darkBlueColor)
        
        createdByLabel.text = "Created by \(event.adminName) on \(GlobalFunctions.shared.formattedTimestamp(ts:event.createdDate, includeDate: true, includeTime: false))"
        createdByLabel.textColor = .lightGray
    }
    
}

class PenaltyCell: UITableViewCell {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var checkedInButton: UIButton!
    @IBOutlet weak var bibNumberLabel: UILabel!
    @IBOutlet weak var penaltyLabel: UILabel!
    @IBOutlet weak var submittedByLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    
    var penalty: Penalty?
    var delegate: PenaltiesTableViewController?
    var eventID: String?
    
    func setUpCell(penalty: Penalty, vc: PenaltiesTableViewController, eventID: String) {
        self.penalty = penalty
        self.delegate = vc
        self.eventID = eventID
        checkedInButton.layer.borderColor = UIColor.lightGray.cgColor
        checkedInButton.layer.borderWidth = 1
        checkedInButton.layer.cornerRadius = 5
        if penalty.checkedIn {
            checkedInButton.setImage(UIImage(named: "checkmark.png"), for: .normal)
        } else {
            checkedInButton.setImage(nil, for: .normal)
        }
        bibNumberLabel.attributedText = GlobalFunctions.shared.bold(string: penalty.bibNumber, size: 20.0, color: .black)
        
        penaltyLabel.text = penalty.penalty
        
        if penalty.edited {
            submittedByLabel.text = "Submitted by \(penalty.submittedBy), Edited"
        } else {
            submittedByLabel.text = "Submitted by \(penalty.submittedBy)"
        }
        submittedByLabel.textColor = .lightGray
        
        timeStampLabel.attributedText = GlobalFunctions.shared.bold(string: GlobalFunctions.shared.formattedTimestamp(ts: penalty.timeStamp, includeDate: false, includeTime: true), size: 14.0, color: appDelegate.darkBlueColor)
        
        cardView.layer.borderWidth = 1
        if ["Blatant Littering", "Drafting"].contains(penalty.penalty) {
            cardView.layer.borderColor = appDelegate.darkBlueColor.cgColor
            cardView.backgroundColor = appDelegate.darkBlueColor
        } else if penalty.penalty == "Other" {
            cardView.layer.borderColor = UIColor.black.cgColor
            cardView.backgroundColor = UIColor.white
        } else {
            cardView.layer.borderColor = appDelegate.yellowColor.cgColor
            cardView.backgroundColor = appDelegate.yellowColor
        }
        
    }
    
    @IBAction func checkedInButtonPressed(_ sender: Any) {
        if (self.delegate?.searchController.isActive)! {
            self.delegate?.searchController.isActive = false
            self.delegate?.searchController.searchBar.text = ""
            self.delegate?.searchController.dismiss(animated: false, completion: nil)
        }
        if let penalty = self.penalty {
            if penalty.checkedIn {
                self.delegate?.confirmUnCheckIn(bibNumber: penalty.bibNumber, eventID: eventID!, penaltyID: penalty.uid)
            } else {
                self.delegate?.confirmCheckIn(bibNumber: penalty.bibNumber, eventID: eventID!, penaltyID: penalty.uid)
            }
        }
    }
    
}

struct Recipient {
    
    let email: String
    let name: String
    var selected: Bool
    
    init(email: String, name: String, selected: Bool) {
        self.name = name
        self.email = email
        self.selected = selected
    }
    
}

struct Edit {
    
    let name: String
    let timeStamp: String
    
    init(name: String, timeStamp: String) {
        self.name = name
        self.timeStamp = timeStamp
    }
    
}


class PinField: UITextField {
    override func deleteBackward() {
        super.deleteBackward()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deletePressed"), object: nil)
    }
}
