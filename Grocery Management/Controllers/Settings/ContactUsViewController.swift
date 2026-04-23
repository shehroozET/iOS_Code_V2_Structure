//
//  HelpViewController.swift
//  Grocery Management
//
//  Created by mac on 13/05/2025.
//

import UIKit
import MessageUI

class ContactUsViewController: UIViewController,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var tf_fullName: UITextField!
    @IBOutlet weak var tf_email: UITextField!
    @IBOutlet weak var tf_message: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contact us"
        self.setupNavigationBackButton(){
            self.navigationController?.dismiss(animated: true)
        }
    }
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        let name = tf_fullName.text ?? ""
        let email = tf_email.text ?? ""
        let message = tf_message.text ?? ""

        sendEmail(name: name, email: email, message: message)
    }
    func sendEmail(name: String, email: String, message: String) {
        guard MFMailComposeViewController.canSendMail() else {
            self.showToastAlert(message:"Mail services are not available")
            return
        }

        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self

        mailComposer.setToRecipients(["support@groceryManagement.com"])
        mailComposer.setSubject("Message from \(name)")
        
        let body = """
        Name: \(name)
        Email: \(email)
        
        Message:
        \(message)
        """
        
        mailComposer.setMessageBody(body, isHTML: false)

        self.present(mailComposer, animated: true)
    }
}
