//
//  SettingsViewController.swift
//  Grocery Management
//
//  Created by mac on 13/05/2025.
//

import UIKit
import GoogleSignIn

class SettingsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    let contentStrings : [String] = ["Edit Profile" , "Notifications" , "Change Password" , "Contact us" , "Invite Friends" , "Terms and Conditions" , "Language" , "Logout" ]
    let contentImages : [String] = ["ic_edit_profile" , "ic_notifications" , "ic_security" , "ic_help" , "ic_help" , "ic_terms_and_conditions" , "ic_language" , "ic_logout" ]
    
    let controllerIds : [String] = ["ProfileViewController" , "NotificationsSettingsViewController" , "ChangePasswordViewController" , "ContactUsViewController"]
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
        cell.name_settings.text = contentStrings[indexPath.row]
        cell.icon_settings.image = UIImage(named: contentImages[indexPath.row])
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath : IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        let settingsBoard = UIStoryboard(name: "Settings", bundle: nil)
        if controllerIds.indices.contains(indexPath.row){
            let selectedController = settingsBoard.instantiateViewController(identifier: controllerIds[indexPath.row])
            selectedController.modalPresentationStyle = .fullScreen
            self.present(selectedController , animated : true)
        } else {
            TokenManager.shared.clear()
            GIDSignIn.sharedInstance.signOut()
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {

                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                let initialNav = storyboard.instantiateViewController(withIdentifier: "InitialNav")

                window.rootViewController = initialNav
                window.makeKeyAndVisible()

                let options: UIView.AnimationOptions = .transitionFlipFromLeft
                UIView.transition(with: window, duration: 0.4, options: options, animations: {}, completion: nil)
            }
//            self.navigationController?.dismiss(animated: true)
        }
    }
}
