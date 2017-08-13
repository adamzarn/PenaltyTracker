//
//  SelectRecipientsViewController.swift
//  PenaltyTracker
//
//  Created by Adam Zarn on 8/12/17.
//  Copyright © 2017 Adam Zarn. All rights reserved.
//

import UIKit
import MessageUI
import Firebase

class SelectRecipientsViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var csvString: String?
    var fileName: String?
    var recipients: [Recipient] = []
    let defaults = UserDefaults.standard
    var currentTextField: UITextField?
    
    @IBOutlet weak var recipientsTableView: UITableView!
    @IBOutlet weak var addRecipientView: UIView!
    var dimView: UIView?
    @IBOutlet weak var sendEmailButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dimView = UIView(frame:UIScreen.main.bounds)
        dimView?.backgroundColor = UIColor(white: 0.4, alpha: 0.5)
        sendEmailButton.tintColor = appDelegate.darkBlueColor
        toolbar.isTranslucent = false
        
    }

    override func viewDidAppear(_ animated: Bool) {
        recipientsTableView.isHidden = true
        addRecipientView.isHidden = true
    
        getRecipients()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.recipients = []
    }
    
    func getRecipients() {
        
        if let recipients = defaults.value(forKey: "recipients") {
            for (key, value) in recipients as! NSDictionary {
                let newRecipient = Recipient(email: key as! String, name: value as! String, selected: false)
                self.recipients.append(newRecipient)
            }
            self.recipients.sort { $0.name < $1.name }
        }
        
        let check = recipients.filter { $0.name == "Me" }
        if check.count == 0 {
            let me = Recipient(email: (Auth.auth().currentUser?.email)!, name: "Me", selected: false)
            self.recipients.insert(me, at: 0)
        }
        
        recipientsTableView.reloadData()
        recipientsTableView.isHidden = false
        
    }
    
    func loadRecipients() {
        var recipientsToLoad: [String:String] = [:]
        for recipient in self.recipients {
            if recipient.name != "Me" {
                recipientsToLoad[recipient.email] = recipient.name
            }
        }
        defaults.setValue(recipientsToLoad, forKey: "recipients")
    }
    
    func sendEmail(recipients: [String]) {
        
        if MFMailComposeViewController.canSendMail() {
        
            if let csvString = csvString, let fileName = fileName {
        
                let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
                
                do {
                    try csvString.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                print("Failed to create file")
                print("\(error)")
                }
                    
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = self
                
                mailComposerVC.setSubject(fileName)
                mailComposerVC.setToRecipients(recipients)
                
                do {
                    let data = try Data(contentsOf: path!)
                    mailComposerVC.addAttachmentData(data, mimeType: "text/csv", fileName: fileName)
                    present(mailComposerVC, animated: false, completion: nil)
                } catch {
                    print(error.localizedDescription)
                }
                
            }
            
        } else {
            displayAlert(title: "Cannot Send Mail", message: "This device is not set up to send mail.")
        }

    }
    
    
    @IBAction func sendEmailButtonPressed(_ sender: Any) {
        var toRecipients: [String] = []
        for recipient in self.recipients {
            if recipient.selected {
                toRecipients.append(recipient.email)
            }
        }
        print(toRecipients)
        sendEmail(recipients: toRecipients)
    }
    
    @IBAction func addRecipientButtonPressed(_ sender: Any) {
        self.view.addSubview(dimView!)
        self.view.bringSubview(toFront: dimView!)
        addRecipientView.isHidden = false
        self.view.bringSubview(toFront: addRecipientView)
    }
    
    @IBAction func cancelAddRecipientButtonPressed(_ sender: Any) {
        dismissAddRecipientView()
    }
    
    @IBAction func submitAddRecipientButtonPressed(_ sender: Any) {
        if nameTextField.text != "" && emailTextField.text != "" {
            let newRecipient = Recipient(email: emailTextField.text!, name: nameTextField.text!, selected: false)
            recipients.append(newRecipient)
            loadRecipients()
            print(defaults.value(forKey: "recipients")!)
            recipientsTableView.reloadData()
            dismissAddRecipientView()
        } else {
            displayAlert(title: "Bad Name or Email", message: "You must provide a name and an email for a new recipient.")
        }
        
    }
    
    func dismissAddRecipientView() {
        currentTextField?.resignFirstResponder()
        addRecipientView.isHidden = true
        dimView?.removeFromSuperview()
    }

}

extension SelectRecipientsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        if result == .failed {
            displayAlert(title: "Email Not Sent", message: "The email failed to send, please try again.")
        } else if result == .sent {
            displayAlert(title: "Email Sent", message: "The email was successfully sent.")
        }
    }
    
}

extension SelectRecipientsViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        textField.becomeFirstResponder()
    }
}


extension SelectRecipientsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipientCell")!
        let recipient = recipients[indexPath.row]
        cell.textLabel?.text = recipient.name
        cell.detailTextLabel?.text = recipient.email
        if recipient.selected {
            cell.accessoryView = checkmarkImageView()
        } else {
            cell.accessoryView = nil
        }
        cell.selectionStyle = .none
        cell.accessoryView?.tintColor = appDelegate.darkBlueColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let selectedRecipient = recipients[indexPath.row]
        if selectedRecipient.selected {
            cell?.accessoryView = nil
        } else {
            cell?.accessoryView = checkmarkImageView()
        }
        tableView.deselectRow(at: indexPath, animated: false)
        recipients[indexPath.row].selected = !recipients[indexPath.row].selected
    }
    
    func checkmarkImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        imageView.image = UIImage(named: "checkmark.png")
        return imageView
    }
    
}
