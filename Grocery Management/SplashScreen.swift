//
//  ViewController.swift
//  Grocery Management
//
//  Created by mac on 18/02/2025.
//

import UIKit


import Alamofire

class SplashScreen: UIViewController {
    
    var tokenManager = TokenManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Config.shared.environment = .staging
    }
    override func viewWillAppear(_ animated : Bool){
        super.viewWillAppear(animated)
        startTimer()
    }
    
    func startTimer(){
        let main = UIStoryboard(name: "Main", bundle: .none)
        let navcontroller = main.instantiateViewController(withIdentifier: "OnBoardingScreen")
        DispatchQueue.main.asyncAfter(deadline: .now()+4){ [self] in
            let dashboard : UIStoryboard? = UIStoryboard(name: "Dashboard", bundle: .none)
            if let token = tokenManager.token, let uid = tokenManager.uid , let client = tokenManager.client{
                if let controller = dashboard?.instantiateViewController(withIdentifier: "DashboardVC")
                {
                    AppLogger.general.info("token \(token) ")
                    AppLogger.general.info("uid \(uid) ")
                    AppLogger.general.info("client \(client) ")
                    self.present(controller, animated: true)
                    
                }
                
            }
                self.navigationController?.pushViewController(navcontroller, animated: true)
            
        }
    }


}

