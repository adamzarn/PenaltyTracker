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

struct Event {
    
    let name: String
    let pin: String
    let city: String
    let state: String
    let date: String
    let startTime: String
    let endTime: String
    let admin: String
    let adminName: String
    
    init(name: String, pin: String, city: String, state: String, date: String, startTime: String, endTime: String, admin: String, adminName: String) {
        self.name = name
        self.pin = pin
        self.city = city
        self.state = state
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.admin = admin
        self.adminName = adminName
    }
    
    func toAnyObject() -> AnyObject {
        return ["name": name,
                "pin": pin,
                "city": city,
                "state": state,
                "date": date,
                "startTime": startTime,
                "endTime": endTime,
                "admin": admin,
                "adminName": adminName] as AnyObject
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
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    
    func setUpCell(event: Event) {
        
        eventNameLabel.attributedText = GlobalFunctions.shared.bold(string: event.name, size: 14.0, color: .black)
        
        locationLabel.attributedText = GlobalFunctions.shared.italic(string: event.city + ", " + event.state, size: 14.0, color: .black)
        
        dateLabel.attributedText = GlobalFunctions.shared.bold(string: event.date, size: 14.0, color: appDelegate.darkBlueColor)
        
        timeLabel.text = event.startTime + " to " + event.endTime
        
        createdByLabel.text = "Created by: \(event.adminName)"
        createdByLabel.textColor = .lightGray
    }
    
}
