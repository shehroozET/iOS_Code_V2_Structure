//
//  ForgotPasswordVC.swift
//  Grocery Management
//
//  Created by mac on 18/02/2025.
//

import UIKit
import ProgressHUD

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var tf_email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Forgot Password"
        tf_email.text = "shehrooz@et.com"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ aniamted : Bool){
        super.viewWillAppear(aniamted)
        self.navigationController?.navigationBar.isHidden = false
        self.setupNavigationBackButton {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func sendEmail(_ sender: Any) {
        guard self.verifyEmail(email: tf_email.text ?? "") else {
            self.showToastAlert(message: "Email not valid")
            return
        }
        sendEmail(email : tf_email.text!)
    }

    func sendEmail(email : String){
        ProgressHUD.animate()
        AuthService.sendCode(email: email) { result in
            switch result {
            case .success(let (response, headers)):
                self.tf_email.text = ""
                AppLogger.general.info("Email send: \(response.message ?? "")")
                ProgressHUD.dismiss()
                let stroyBoard = UIStoryboard(name: "ForgotPassword", bundle: nil)
                if let controller = stroyBoard.instantiateViewController(identifier: "AuthenticationVC") as? AuthenticationVC{
                    controller.email = email
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                
            case .failure(let error):
                AppLogger.error.error("Code cannot be sent: -  \(error.localizedDescription)")
                ProgressHUD.failed("Cannot send code, Please try again later")
            }
        }
    }

}
