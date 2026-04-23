//
//  NotificationsViewController.swift
//  Grocery Management
//
//  Created by mac on 30/04/2025.
//

import UIKit

class NotificationsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {
        
    @IBOutlet weak var tableView: UITableView!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.delegate = self
            tableView.dataSource = self
            
            // Do any additional setup after loading the view.
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 15
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsTableViewCell") as! NotificationsTableViewCell
            
            return cell
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath : IndexPath){
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
