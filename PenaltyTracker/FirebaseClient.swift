//
//  FirebaseClient.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/4/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import Alamofire
import AlamofireImage

class FirebaseClient: NSObject {
    
    let ref = Database.database().reference()
    let storageRef = Storage.storage().reference()
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
                        let admin = eventObject.value(forKey: "admin") as! String
                        let adminName = eventObject.value(forKey: "adminName") as! String
                        let event = Event(uid: key as! String, name: name, pin: pin, city: city, state: state, date: date, createdDate: createdDate, admin: admin, adminName: adminName)
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
    
    func getPenalties(eventID: String, completion: @escaping (_ penalties: [Penalty]?,_ checkedInCount: Int?, _ error: NSString?) -> ()) {
        self.ref.child("Penalties").child(eventID).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.exists() {
                if let data = snapshot.value {
                    var penalties: [Penalty] = []
                    var checkedInCount = 0
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
                        let editedExists = penaltyObject.value(forKey: "edited") != nil
                        var edited = false
                        if editedExists {
                            edited = penaltyObject.value(forKey: "edited") as! Bool
                        }
                        let editsExist = penaltyObject.value(forKey: "edits") != nil
                        var edits: [String:String] = [:]
                        if editsExist {
                            edits = penaltyObject.value(forKey: "edits") as! [String:String]
                        }
                        let coordinatesExist = penaltyObject.value(forKey: "lat") != nil
                        var lat = ""
                        var long = ""
                        if coordinatesExist {
                            lat = penaltyObject.value(forKey: "lat") as! String
                            long = penaltyObject.value(forKey: "long") as! String
                        }
                        let newPenalty = Penalty(uid: key as! String, bibNumber: bibNumber, gender: gender, bikeType: bikeType, bikeColor: bikeColor, helmetColor: helmetColor, topColor: topColor, pantColor: pantColor, penalty: penalty, bikeLengths: bikeLengths, seconds: seconds, approximateMile: approximateMile, notes: notes, submittedBy: submittedBy, timeStamp: timeStamp, checkedIn: checkedIn, edited: edited, edits: edits, lat: lat, long: long)
                        penalties.append(newPenalty)
                        if checkedIn {
                            checkedInCount += 1
                        }
                    }
                    completion(penalties, checkedInCount, nil)
                } else {
                    completion(nil, nil, "Could not retrieve Data")
                }
            } else {
                completion(nil, nil, "No Penalties Yet")
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
                    bikes.append("Other")
                    
                    var colors: [String] = []
                    let colorsDict = dict.value(forKey: "Colors") as! NSDictionary
                    for (_, value) in colorsDict {
                        colors.append(value as! String)
                    }
                    colors.sort { $0 < $1 }
                    colors.append("Other")
                    
                    var penaltyTypes: [PenaltyType] = []
                    let penaltyTypesDict = dict.value(forKey: "PenaltyTypes") as! NSDictionary
                    for (_, value) in penaltyTypesDict {
                        let name = (value as AnyObject).value(forKey: "name") as! String
                        let color = (value as AnyObject).value(forKey: "color") as! String
                        let newPenaltyType = PenaltyType(name: name, color: color)
                        penaltyTypes.append(newPenaltyType)
                    }
                    penaltyTypes.sort { $0.name < $1.name }
                    penaltyTypes.append(PenaltyType(name:"Other",color:""))
                    
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
    
    func createEvent(uid: String, event: Event, completion: @escaping (_ success: Bool?, _ message: NSString?) -> ()) {
        var eventsRef: DatabaseReference
        if uid == "" {
            eventsRef = self.ref.child("Events").childByAutoId()
        } else {
            eventsRef = self.ref.child("Events").child(uid)
        }
        eventsRef.setValue(event.toAnyObject()) { (error, ref) -> Void in
            if error != nil {
                completion(false, "error")
            } else {
                if uid == "" {
                    completion(true, "Your event was successfully created. Would you like to send invite emails to this event's officials?")
                } else {
                    completion(true, "Your event was successfully edited.")
                }
            }
        }
    }
    
    func postPenalty(eventID: String, penaltyID: String, penalty: Penalty,
                     imageData: Data, shouldUploadPhoto: Bool,
                     videoData: Data, shouldUploadVideo: Bool,
                     audioData: Data, shouldUploadAudio: Bool,
                     completion: @escaping (_ success: Bool?, _ message: NSString?) -> ()) {

        var tasksCompleted = [false, !shouldUploadPhoto, !shouldUploadVideo, !shouldUploadAudio]
        
        var penaltyRef: DatabaseReference!
        var successMessage: NSString!
        if penaltyID == "" {
            penaltyRef = self.ref.child("Penalties").child(eventID).childByAutoId()
            successMessage = "The penalty was successfully logged. We'll take you back to the Penalties list now."
        } else {
            penaltyRef = self.ref.child("Penalties").child(eventID).child(penaltyID)
            successMessage = "The penalty was successfully edited."
        }
        
        let imageRef = self.storageRef.child(eventID).child(penaltyRef.key).child("profilePhoto")
        let videoRef = self.storageRef.child(eventID).child(penaltyRef.key).child("video")
        let audioRef = self.storageRef.child(eventID).child(penaltyRef.key).child("audio")
        
        penaltyRef.setValue(penalty.toAnyObject()) { (error, ref) -> Void in
            tasksCompleted[0] = true
            if error != nil {
                print("0 error")
                if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                    completion(false, "Error")
                }
            } else {
                print("0 success")
                if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                    completion(true, successMessage)
                }
            }
        }
        
        if !tasksCompleted[1] {
            self.uploadData(ref: imageRef, data: imageData) { (success) -> () in
                tasksCompleted[1] = true
                if let success = success {
                    if success {
                        print("1 success")
                        if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                            completion(true, successMessage)
                        }
                    } else {
                        print("1 error")
                        if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                            completion(false, "Error")
                        }
                    }
                } else {
                    print("1 error")
                    if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                        completion(false, "Error")
                    }
                }
            }
        } else {
            print("1 success - didn't need to do")
            if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                completion(true, successMessage)
            }
        }
        
        if !tasksCompleted[2] {
            self.uploadData(ref: videoRef, data: videoData) { (success) -> () in
                tasksCompleted[2] = true
                if let success = success {
                    if success {
                        print("2 success")
                        if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                            completion(true, successMessage)
                        }
                    } else {
                        print("2 error")
                        if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                            completion(false, "Error")
                        }
                    }
                } else {
                    print("2 error")
                    if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                        completion(false, "Error")
                    }
                }
            }
        } else {
            print("2 success - didn't need to do")
            if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                completion(true, successMessage)
            }
        }
        
        if !tasksCompleted[3] {
            self.uploadData(ref: audioRef, data: audioData) { (success) -> () in
                tasksCompleted[3] = true
                if let success = success {
                    if success {
                        print("3 success")
                        if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                            completion(true, successMessage)
                        }
                    } else {
                        print("3 error")
                        if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                            completion(false, "Error")
                        }
                    }
                } else {
                    print("3 error")
                    if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                        completion(false, "Error")
                    }
                }
            }
        } else {
            print("3 success - didn't need to do")
            if self.allTasksCompleted(tasksCompleted: tasksCompleted) {
                completion(true, successMessage)
            }
        }
        
  
    }
    
    func allTasksCompleted(tasksCompleted: [Bool]) -> Bool {
        if tasksCompleted == [true, true, true, true] {
            return true
        } else {
            return false
        }
    }
    
    func uploadData(ref: StorageReference, data: Data, completion: @escaping (_ success: Bool?) -> ()) {
        ref.putData(data, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
        
    func getProfilePhoto(eventID: String, penaltyID: String, completion: @escaping (_ image: UIImage?) -> ()) {
        let imageRef = self.storageRef.child(eventID).child(penaltyID).child("profilePhoto")
        imageRef.getMetadata { (metadata, error) -> () in
            if let metadata = metadata {
                let downloadUrl = metadata.downloadURL()
                Alamofire.request(downloadUrl!, method: .get).responseImage { response in
                    guard let image = response.result.value else {
                        completion(nil)
                        return
                    }
                    completion(image)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func getVideo(eventID: String, penaltyID: String, completion: @escaping (_ video: Data?, _ error: Error?) -> ()) {
        let videoRef = self.storageRef.child(eventID).child(penaltyID).child("video")
        videoRef.getData(maxSize: INT64_MAX) { (data, error) in
            if let error = error {
                completion(nil, error)
            } else {
                completion(data, nil)
            }
        }
    }
    
    func getAudio(eventID: String, penaltyID: String, completion: @escaping (_ audio: Data?, _ error: Error?) -> ()) {
        let audioRef = self.storageRef.child(eventID).child(penaltyID).child("audio")
        audioRef.getData(maxSize: INT64_MAX) { (data, error) in
            if let error = error {
                completion(nil, error)
            } else {
                completion(data, nil)
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
    
    func deleteEvent(eventID: String, completion: @escaping (_ success: Bool?) -> ()) {
        let eventToDeleteRef = self.ref.child("Events").child(eventID)
        let penaltiesToDeleteRef = self.ref.child("Penalties").child(eventID)
        
        eventToDeleteRef.removeValue() { (error, ref) -> Void in
            if error != nil {
                completion(false)
            } else {
                penaltiesToDeleteRef.observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.exists() {
                        if let data = snapshot.value {
                            let penalties = data as! NSDictionary
                            let penaltyIDs = penalties.allKeys as! [String]
                            penaltiesToDeleteRef.removeValue() { (error, ref) -> Void in
                                if error != nil {
                                    completion(false)
                                } else {
                                    var foldersDeleted = 0
                                    for penaltyID in penaltyIDs {
                                        let imageRef = self.storageRef.child(eventID).child(penaltyID).child("profilePhoto")
                                        let videoRef = self.storageRef.child(eventID).child(penaltyID).child("video")
                                        let audioRef = self.storageRef.child(eventID).child(penaltyID).child("audio")
                                        var tasksCompleted = [false, false, false]
                                        imageRef.delete() { (error) -> Void in
                                            tasksCompleted[0] = true
                                            if tasksCompleted == [true, true, true] {
                                                foldersDeleted = foldersDeleted + 1
                                                print(foldersDeleted)
                                            }
                                            if foldersDeleted == penaltyIDs.count {
                                                completion(true)
                                            }
                                        }
                                        videoRef.delete() { (error) -> Void in
                                            tasksCompleted[1] = true
                                            if tasksCompleted == [true, true, true] {
                                                foldersDeleted = foldersDeleted + 1
                                                print(foldersDeleted)
                                            }
                                            if foldersDeleted == penaltyIDs.count {
                                                completion(true)
                                            }
                                        }
                                        audioRef.delete() { (error) -> Void in
                                            tasksCompleted[2] = true
                                            if tasksCompleted == [true, true, true] {
                                                foldersDeleted = foldersDeleted + 1
                                                print(foldersDeleted)
                                            }
                                            if foldersDeleted == penaltyIDs.count {
                                                completion(true)
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            completion(false)
                        }
                    } else {
                        completion(true)
                    }
                })
            }
        }
    }
    
    func deletePenalty(eventID: String, penaltyID: String, completion: @escaping (_ success: Bool?) -> ()) {
        let penaltyToDeleteRef = self.ref.child("Penalties").child(eventID).child(penaltyID)
        let imageRef = self.storageRef.child(eventID).child(penaltyID).child("profilePhoto")
        let videoRef = self.storageRef.child(eventID).child(penaltyID).child("video")
        let audioRef = self.storageRef.child(eventID).child(penaltyID).child("audio")
        penaltyToDeleteRef.removeValue() { (error, ref) -> Void in
            if error != nil {
                completion(false)
            } else {
                var tasksCompleted = [false, false, false]
                imageRef.delete() { (error) -> Void in
                    tasksCompleted[0] = true
                    if tasksCompleted == [true, true, true] {
                        completion(true)
                    }
                }
                videoRef.delete() { (error) -> Void in
                    tasksCompleted[1] = true
                    if tasksCompleted == [true, true, true] {
                        completion(true)
                    }
                }
                audioRef.delete() { (error) -> Void in
                    tasksCompleted[2] = true
                    if tasksCompleted == [true, true, true] {
                        completion(true)
                    }
                }
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
