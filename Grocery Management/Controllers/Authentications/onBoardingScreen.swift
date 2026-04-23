//
//  onBoardingScreen.swift
//  Grocery Management
//
//  Created by mac on 25/03/2025.
//

import UIKit
import Vision
import GoogleSignIn
import ProgressHUD


class OnBoardingScreen: UIViewController {
    @IBOutlet weak var loginWithGoogle: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func SignIn(_ sender: Any) {
        let main = UIStoryboard(name: "Main", bundle: .none)
        let navcontroller = main.instantiateViewController(withIdentifier: "LoginVC")
       
            self.navigationController?.pushViewController(navcontroller, animated: true)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func loginWithGoogle(_ sender: Any) {
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            let dashboard : UIStoryboard = UIStoryboard(name: "Dashboard", bundle: .none)
            AppLogger.debug.info("Google login scuccess: response - \(signInResult)")
            
            let controller = dashboard.instantiateViewController(withIdentifier: "DashboardVC")
            ProgressHUD.animate()
            let user = signInResult?.user
            let fullName = user?.profile?.name ?? "No Name"
            let email = user?.profile?.email ?? "No Email"
            AuthService.googleSignIn(email:  email, name: fullName) { result in
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
                    AppLogger.general.info("Login Successfull: \(response.data?.email ?? "")")
                    ProgressHUD.dismiss()
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
    
    
}
