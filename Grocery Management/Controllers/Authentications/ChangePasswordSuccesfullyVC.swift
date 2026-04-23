//
//  ChangePasswordVC.swift
//  Grocery Management
//
//  Created by mac on 24/04/2025.
//

import UIKit

class ChangePasswordSuccesfullyVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ aniamted : Bool){
        super.viewWillAppear(aniamted)
        self.setupNavigationBackButton {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    @IBAction func confirmation(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    

}
