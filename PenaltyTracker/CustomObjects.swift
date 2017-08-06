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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.barTintColor = UIColor.black
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
}
