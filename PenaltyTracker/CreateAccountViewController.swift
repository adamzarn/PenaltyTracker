//
//  CreateAccountViewController.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/4/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import Firebase

class CreateAccountViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var aiv: UIActivityIndicatorView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    //Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.setTitleColor(appDelegate.darkBlueColor, for: .normal)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setUpView()
    }
    
    //IBActions
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        aiv.isHidden = false
        aiv.startAnimating()
        if nameTextField.text != "" {
            verifyPassword()
        } else {
            displayAlert(title: "No Name", message: "You must provide a name.")
        }
    }
    
    //Helper methods
    
    func setUpView() {
        aiv.isHidden = true
    }
    
    func displayAlert(title: String, message: String) {
        self.aiv.isHidden = true
        self.aiv.stopAnimating()
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    
    //Text Field Delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Create Account methods
    
    func verifyPassword() {
        if passwordTextField.text! != verifyPasswordTextField.text! {
            self.displayAlert(title: "Password Mismatch", message: "Please make sure that your passwords match.")
        } else {
            createUser()
        }
    }
    
    func createUser() {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if GlobalFunctions.shared.hasConnectivity() {
            
            Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
                if let user = user {
                    FirebaseClient.shared.addNewUser(uid: user.uid, name: self.nameTextField.text!)
                    let eventsNC = self.storyboard?.instantiateViewController(withIdentifier: "EventsNavigationController") as! MyNavigationController
                    self.present(eventsNC, animated: false, completion: nil)
                } else {
                    
                    if email == "" {
                        self.displayAlert(title: "No Email", message: "You must provide an email.")
                    } else {
                        self.displayAlert(title: "Error", message: (error?.localizedDescription)!)
                    }
                }
            }
            
        } else {
            
            displayAlert(title: "No Internet Connectivity", message: "Establish an Internet Connection and try again.")
            
        }
        
    }
    
}
