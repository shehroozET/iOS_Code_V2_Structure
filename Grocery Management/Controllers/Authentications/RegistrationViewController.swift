//
//  RegistrationViewController.swift
//  Grocery Management
//
//  Created by mac on 18/02/2025.
//

import UIKit
import ProgressHUD

class RegistrationViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var tf_cPassword: UITextField!
    @IBOutlet weak var tf_username: UITextField!
    @IBOutlet weak var tf_email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tf_cPassword.returnKeyType = .done
        tf_cPassword.delegate = self
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    @IBAction func registerTap(_ sender: Any) {
        
        
        if let username = tf_username.text?.trimmingCharacters(in: [" "]) {
            if username.isEmpty{
                showToastAlert(message: "Username must not be empty")
                return
            }
        }
        guard verifyEmail(email: tf_email.text ?? "") else {
            showToastAlert(message: "Invalid email address")
            return
        }
        guard tf_password.text != nil else {
            showToastAlert(message: "Password must not be empty")
            return
        }
        guard tf_password.text == tf_cPassword.text else {
            showToastAlert(message: "Password doesn't match")
            return
        }
        ProgressHUD.animate()
        AuthService.register(user_name : tf_username.text ?? "" , email: tf_email.text ?? "", password: tf_password.text ?? "", password_confirmation: tf_password.text ?? "" ) { result in
            switch result {
            case .success(let (response, _)):
                self.showAlertAction(title: "", message: "User \(String(describing: response.data?.email ?? "")) registered successful"){
                    self.navigationController?.popViewController(animated: true)
                }
                
                ProgressHUD.dismiss()
            case .failure(let error):
                
                print("Error:", error.localizedDescription)
                
                switch error {
                case .backendError(let data):
                    do {
                        let decoded = try JSONDecoder().decode(RegistrationResponse.self, from: data)
                        if let messages = decoded.errors?.fullMessages {
                            ProgressHUD.failed(messages.joined(separator: "\n"))
                        } else {
                            ProgressHUD.failed("Something went wrong.")
                        }
                    } catch {
                        ProgressHUD.failed("Failed to parse error.")
                    }
                    
                default:
                    ProgressHUD.failed(error.localizedDescription)
                }
                
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
