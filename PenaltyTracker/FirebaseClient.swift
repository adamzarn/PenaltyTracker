//
//  FirebaseClient.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/4/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class FirebaseClient: NSObject {
    
    let ref = Database.database().reference()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func getEvents(completion: @escaping (_ events: [Event]?, _ error: NSString?) -> ()) {
        self.ref.child("Events").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                if let data = snapshot.value {
                    var events: [Event] = []
                    for (_,value) in data as! NSDictionary {
                        let eventObject = value as AnyObject
                        let name = eventObject.value(forKey: "name") as! String
                        let pin = eventObject.value(forKey: "pin") as! String
                        let city = eventObject.value(forKey: "city") as! String
                        let state = eventObject.value(forKey: "state") as! String
                        let date = eventObject.value(forKey: "date") as! String
                        let startTime = eventObject.value(forKey: "startTime") as! String
                        let endTime = eventObject.value(forKey: "endTime") as! String
                        let admin = eventObject.value(forKey: "admin") as! String
                        let adminName = eventObject.value(forKey: "adminName") as! String
                        let event = Event(name: name, pin: pin, city: city, state: state, date: date, startTime: startTime, endTime: endTime, admin: admin, adminName: adminName)
                        events.append(event)
                    }
                    completion(events, nil)
                } else {
                    completion(nil, "Could not retrieve Data")
                }
            } else {
                completion(nil, "No Events Yet")
            }
        })
    }
    
    func getUserData(uid: String, completion: @escaping (_ user: User?, _ error: NSString?) -> ()) {
        self.ref.child("Users").child(uid).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                if let data = snapshot.value {
                    let name = (data as AnyObject).value(forKey: "name") as! String
                    let user = User(name: name)
                    completion(user, nil)
                } else {
                    completion(nil, "Data could not be retrieved")
                }
            } else {
                completion(nil, "No User")
            }
        })
    }
    
    func addNewUser(uid: String, name: String) {
        
        let userRef = self.ref.child("Users/\(uid)")
        userRef.child("name").setValue(name)
        
    }
    
    func createEvent(event: Event, completion: @escaping (_ success: Bool?) -> ()) {
        let eventsRef = self.ref.child("Events").childByAutoId()
        eventsRef.setValue(event.toAnyObject()) { (error, ref) -> Void in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        }

    }
    
    func logout(vc: UIViewController) {
        do {
            try Auth.auth().signOut()
            let loginVC = vc.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            vc.present(loginVC, animated: false, completion: nil)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    
    static let shared = FirebaseClient()
    private override init() {
        super.init()
    }
    
}
