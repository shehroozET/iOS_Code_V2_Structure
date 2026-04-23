//
//  LoginViewController.swift
//  Grocery Management
//
//  Created by mac on 18/02/2025.
//

import UIKit
import ProgressHUD
import OSLog

enum LoginError: Error {
    case wrongInformation
}

struct Mutations {
    var pagesRemaining : Int

    mutating func copy(count: Int) throws {
        guard count <= pagesRemaining else {
            throw LoginError.wrongInformation
        }
        pagesRemaining -= count
    }
}

class LoginViewController: UIViewController , UITextFieldDelegate {
    
    var countRemaining : Int = 10
  
    private let togglePasswordButton = UIButton(type: .custom)
    private let tickImageView = UIImageView()
    @IBOutlet weak var lblTermsAndPrivacy: UILabel!
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var lbl_signup: UILabel!
    @IBOutlet weak var tf_email: UITextField!
    @IBOutlet weak var lbl_forgotPassword: UILabel!
    var main : UIStoryboard? = nil
    var dashboard : UIStoryboard? = nil
    var forgotPassword : UIStoryboard? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        main = UIStoryboard(name: "Main", bundle: .none)
        forgotPassword = UIStoryboard(name: "ForgotPassword", bundle: .none)
        dashboard = UIStoryboard(name: "Dashboard", bundle: .none)
        
        togglePasswordButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        togglePasswordButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
        togglePasswordButton.tintColor = .gray
        togglePasswordButton.addTarget(self, action: #selector(togglePasswordView), for: .touchUpInside)
        
        tf_password.rightView = togglePasswordButton
        tf_password.rightViewMode = .always
        
        tf_email.delegate = self
        tf_email.keyboardType = .emailAddress
        tf_email.autocapitalizationType = .none
        tf_email.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        // Prepare tick image (hidden initially)
        tickImageView.image = UIImage(systemName: "checkmark.circle.fill")
        tickImageView.tintColor = .systemGreen
        tickImageView.contentMode = .scaleAspectFit
        tickImageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        tf_email.rightView = tickImageView
        tf_email.rightViewMode = .never
        
    }
    @objc func textDidChange(_ textField: UITextField) {
        if let text = textField.text, verifyEmail(email: text) {
                tf_email.rightViewMode = .always
            } else {
                tf_email.rightViewMode = .never
            }
        }
    
    @objc func togglePasswordView() {
        tf_password.isSecureTextEntry.toggle()
        togglePasswordButton.isSelected.toggle()
        
        // Fix cursor position bug
        if let existingText = tf_password.text, tf_password.isSecureTextEntry {
            tf_password.deleteBackward()
            tf_password.insertText(existingText)
        }
    }
    
    @IBAction func moveToForgotPass(_ sender: Any){
        if let controller = forgotPassword?.instantiateViewController(withIdentifier: "ForgotPassword"){
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    @IBAction func registerUser(_ sender: Any){
        if let controller = main?.instantiateViewController(withIdentifier: "RegisterVC"){
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
   
    
    @IBAction func loginAction(_ sender: Any) {
        AppLogger.general.info("Login Pressed")
       
        if let email = tf_email.text , email.trimmingCharacters(in: [" "]) != ""{
            guard verifyEmail(email: email) else {
                showToastAlert(message: "Invalid email address")
                return
            }
        } else {
            showToastAlert(message: "Email must not be empty")
            return
        }
        
        if let controller = dashboard?.instantiateViewController(withIdentifier: "DashboardVC")
        {
            ProgressHUD.animate()
            AuthService.login(email: tf_email.text ?? "", password: tf_password.text ?? "") { result in
                switch result {
                case .success(let (response, headers)):
                    print("Login successful: \(String(describing: response.data?.email))")
                    
                    if let headerDict = headers as? [String: Any] {
                        let token = headerDict.first { $0.key.lowercased() == "access-token" }?.value as? String
                        let client = headerDict.first { $0.key.lowercased() == "client" }?.value as? String
                        let uid = headerDict.first { $0.key.lowercased() == "uid" }?.value as? String
                        let id = response.data?.id ?? 0

                        TokenManager.shared.save(token: token, client: client, uid: uid, userIDKey: String(id))
                    }
                    self.tf_email.text = ""
                    self.tf_password.text = ""
                    AppLogger.general.info("Login Successfull: \(response.data?.email ?? "")")
                    ProgressHUD.dismiss()
                    if let data = response.data
                    {
                        UserSettings.shared.update(settings: [
                            "sound": data.setting?.sound ?? false,
                            "vibrate": data.setting?.vibrate ?? false,
                            "push_notification": data.setting?.pushNotification ?? false,
                            "email_notification": data.setting?.emailNotification ?? false,
                            "user_name": data.userName ?? "Groceipt user",
                            "user_image": data.profileImage ?? "",
                            "email": data.email ?? "",
                            "phone": data.phone ?? "",
                            "gender": data.gender ?? "",
                            "location": data.location ?? "",
                            "currency": data.currency ?? "$",
                            "id": data.id ?? 0
                        ])
                    }
                    
                    self.present(controller, animated: true)
                    
                case .failure(let error):
                    AppLogger.error.error("Login failed: \(error.localizedDescription)")
                    switch error {
                    case .backendError(let data):
                        do {
                            let decoded = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                            if let messages = decoded.errors {
                                ProgressHUD.failed(messages.joined(separator: "\n"))
                            } else {
                                ProgressHUD.failed("Something went wrong.")
                            }
                        } catch {
                            ProgressHUD.failed("Data corrupted")
                        }
                        
                    default:
                        ProgressHUD.failed(error.localizedDescription)
                    }
                }
            }

            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}

