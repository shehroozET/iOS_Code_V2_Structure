//
//  NotificationsViewController.swift
//  Grocery Management
//
//  Created by mac on 05/05/2025.
//

import UIKit
import ProgressHUD

class NotificationsSettingsViewController: UIViewController {

    @IBOutlet weak var switch_email: UISwitch!
    @IBOutlet weak var switch_notification: UISwitch!
    @IBOutlet weak var switch_sound: UISwitch!
    @IBOutlet weak var switch_vibrate: UISwitch!
    
    let settingsUpdateQueue = DispatchQueue(label: "com.et.groceryManagement")
    let updateSemaphore = DispatchSemaphore(value: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBackButton {
            self.navigationController?.dismiss(animated: true)
        }
        setupSettings()
    }
    func setupSettings(){
        switch_email.setOn(UserSettings.shared.emailNotification, animated: false)
        switch_notification.setOn(UserSettings.shared.pushNotification, animated: false)
        switch_sound.setOn(UserSettings.shared.sound, animated: false)
        switch_vibrate.setOn(UserSettings.shared.vibrate, animated: false)
    }
    
    @IBAction func sound_switch_triggered(_ sender: Any) {
        enqueueSettingsUpdate()
    }
    
    @IBAction func vibrate_switch_triggered(_ sender: Any) {
        enqueueSettingsUpdate()
    }
    @IBAction func push_notification_switch_triggered(_ sender: Any) {
        enqueueSettingsUpdate()
    }
    @IBAction func email_notification_switch_triggered(_ sender: Any) {
        enqueueSettingsUpdate()
    }
    
    
    private func enqueueSettingsUpdate() {
        settingsUpdateQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.updateSemaphore.wait()
            
            let group = DispatchGroup()
            group.enter()
            
            DispatchQueue.main.async {
                self.updateSettings {
                    group.leave()
                }
            }
            
            group.wait()
            
            self.updateSemaphore.signal()
        }
    }
    func updateSettings(completion: @escaping () -> Void) {
        AuthService.updateSettings(
            switch_sound: switch_sound.isOn,
            switch_vibrate: switch_vibrate.isOn,
            switch_push_notification: switch_notification.isOn,
            switch_email_notification: switch_email.isOn
        ) { result in
            switch result {
            case .success((let response, _)):
                UserSettings.shared.sound = response.data?.sound ?? false
                UserSettings.shared.vibrate = response.data?.vibrate ?? false
                UserSettings.shared.pushNotification = response.data?.pushNotification ?? false
                UserSettings.shared.emailNotification = response.data?.emailNotification ?? false
                AppLogger.debug.info("Update Settings API success :")
            case .failure(let error):
                AppLogger.error.error("Update Settings API failed : \(error.localizedDescription)")
            }
            
            ProgressHUD.dismiss()
            completion()
        }
    }
    
}
