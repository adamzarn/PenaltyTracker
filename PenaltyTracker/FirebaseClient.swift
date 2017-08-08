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
                    for (key, value) in data as! NSDictionary {
                        let eventObject = value as AnyObject
                        let name = eventObject.value(forKey: "name") as! String
                        let pin = eventObject.value(forKey: "pin") as! String
                        let city = eventObject.value(forKey: "city") as! String
                        let state = eventObject.value(forKey: "state") as! String
                        let date = eventObject.value(forKey: "date") as! String
                        let createdDate = eventObject.value(forKey: "createdDate") as! String
                        let startTime = eventObject.value(forKey: "startTime") as! String
                        let endTime = eventObject.value(forKey: "endTime") as! String
                        let admin = eventObject.value(forKey: "admin") as! String
                        let adminName = eventObject.value(forKey: "adminName") as! String
                        let event = Event(uid: key as! String, name: name, pin: pin, city: city, state: state, date: date, createdDate: createdDate, startTime: startTime, endTime: endTime, admin: admin, adminName: adminName)
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
    
    func getPenalties(eventID: String, completion: @escaping (_ penalties: [Penalty]?, _ error: NSString?) -> ()) {
        self.ref.child("Penalties").child(eventID).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                if let data = snapshot.value {
                    var penalties: [Penalty] = []
                    for (key, value) in data as! NSDictionary {
                        let penaltyObject = value as AnyObject
                        let bibNumber = penaltyObject.value(forKey: "bibNumber") as! String
                        let gender = penaltyObject.value(forKey: "gender") as! String
                        let bikeType = penaltyObject.value(forKey: "bikeType") as! String
                        let bikeColor = penaltyObject.value(forKey: "bikeColor") as! String
                        let helmetColor = penaltyObject.value(forKey: "helmetColor") as! String
                        let topColor = penaltyObject.value(forKey: "topColor") as! String
                        let pantColor = penaltyObject.value(forKey: "pantColor") as! String
                        let penalty = penaltyObject.value(forKey: "penalty") as! String
                        let bikeLengths = penaltyObject.value(forKey: "bikeLengths") as! String
                        let seconds = penaltyObject.value(forKey: "seconds") as! String
                        let approximateMile = penaltyObject.value(forKey: "approximateMile") as! String
                        let notes = penaltyObject.value(forKey: "notes") as! String
                        let submittedBy = penaltyObject.value(forKey: "submittedBy") as! String
                        let timeStamp = penaltyObject.value(forKey: "timeStamp") as! String
                        let checkedIn = penaltyObject.value(forKey: "checkedIn") as! Bool
                        let newPenalty = Penalty(uid: key as! String, bibNumber: bibNumber, gender: gender, bikeType: bikeType, bikeColor: bikeColor, helmetColor: helmetColor, topColor: topColor, pantColor: pantColor, penalty: penalty, bikeLengths: bikeLengths, seconds: seconds, approximateMile: approximateMile, notes: notes, submittedBy: submittedBy, timeStamp: timeStamp, checkedIn: checkedIn)
                        penalties.append(newPenalty)
                    }
                    completion(penalties, nil)
                } else {
                    completion(nil, "Could not retrieve Data")
                }
            } else {
                completion(nil, "No Penalties Yet")
            }
        })
    }
    
    func getDescriptors(completion: @escaping (_ bikes: [String]?, _ colors: [String]?, _ penaltyTypes: [PenaltyType]?, _ error: NSString?) -> ()) {
        self.ref.child("Descriptors").observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                if let data = snapshot.value {
                    let dict = data as! NSDictionary
                    
                    var bikes: [String] = []
                    let bikesDict = dict.value(forKey: "Bikes") as! NSDictionary
                    for (_, value) in bikesDict {
                        bikes.append(value as! String)
                    }
                    bikes.sort { $0 < $1 }
                    
                    var colors: [String] = []
                    let colorsDict = dict.value(forKey: "Colors") as! NSDictionary
                    for (_, value) in colorsDict {
                        colors.append(value as! String)
                    }
                    colors.sort { $0 < $1 }
                    
                    var penaltyTypes: [PenaltyType] = []
                    let penaltyTypesDict = dict.value(forKey: "PenaltyTypes") as! NSDictionary
                    for (_, value) in penaltyTypesDict {
                        let name = (value as AnyObject).value(forKey: "name") as! String
                        let color = (value as AnyObject).value(forKey: "color") as! String
                        let newPenaltyType = PenaltyType(name: name, color: color)
                        penaltyTypes.append(newPenaltyType)
                    }
                    penaltyTypes.sort { $0.name < $1.name }
                    
                    completion(bikes, colors, penaltyTypes, nil)
                } else {
                    completion(nil, nil, nil, "Could not retrieve Data")
                }
            } else {
                completion(nil, nil, nil, "Error")
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
    
    func postPenalty(eventID: String, penalty: Penalty, completion: @escaping (_ success: Bool?) -> ()) {
        let penaltyRef = self.ref.child("Penalties").child(eventID).childByAutoId()
        penaltyRef.setValue(penalty.toAnyObject()) { (error, ref) -> Void in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func checkIn(eventID: String, penaltyID: String, completion: @escaping (_ success: Bool?) -> ()) {
        let penaltyRef = self.ref.child("Penalties").child(eventID).child(penaltyID).child("checkedIn")
        penaltyRef.setValue(true) { (error, ref) -> Void in
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func unCheckIn(eventID: String, penaltyID: String, completion: @escaping (_ success: Bool?) -> ()) {
        let penaltyRef = self.ref.child("Penalties").child(eventID).child(penaltyID).child("checkedIn")
        penaltyRef.setValue(false) { (error, ref) -> Void in
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
