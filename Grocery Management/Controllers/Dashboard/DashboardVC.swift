//
//  DashboardVC.swift
//  Grocery Management
//
//  Created by mac on 18/02/2025.
//

import UIKit
import AlamofireImage

class DashboardVC: UIViewController, UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableCell", for: indexPath) as! HistoryTableCell
        if let data = listData?[indexPath.row]{
            cell.name.text = data.name
            cell.icon.image = UIImage(named: data.iconName)
            cell.date.text = self.getDateInString(date: data.date)
            cell.totalItems.text = "Total items: \(data.totalItems)"
        }
        
        return cell
    }
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath : IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let data = listData?[indexPath.row] {
            let clickedItem = HistoryItem(id: data.id, name: data.name , date: data.date, shareList: data.shareList, totalItems: data.totalItems , iconName: data.iconName , color: data.color )
            HistoryManager.shared.addToHistory(clickedItem)
            
            let board = UIStoryboard(name: "bucket", bundle: nil)

            let itemsController = board.instantiateViewController(identifier: "BucketItemsViewController") as! BucketItemsViewController
            itemsController.bucketTitle = data.name
            itemsController.bucketID = data.id
            itemsController.isFromHistory = true
            itemsController.sharedListData = data.shareList
            itemsController.bucketColor = data.color

            let bucketListVC = board.instantiateViewController(withIdentifier: "BucketListViewController") as! UINavigationController
           
            bucketListVC.viewControllers = [ itemsController]

            bucketListVC.modalPresentationStyle = .fullScreen
            self.present(bucketListVC, animated: true)
            
        }
    }
    

    @IBAction func settings(_ sender: Any) {
        self.tabBarController?.selectedIndex = 4
    }
    @IBOutlet weak var viewDashboard: UIView!
    
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var tableHistory: UITableView!
    
    var listData : [HistoryItem]?
    
    
    @IBAction func notificationsCOntroller(_ sender: Any) {
        self.tabBarController?.selectedIndex = 3
    }
    @IBAction func bucketList(_ sender: Any) {
        let bucketBoard = UIStoryboard(name: "bucket", bundle: nil)
        let bucketController = bucketBoard.instantiateViewController(withIdentifier: "BucketListViewController")
        bucketController.modalPresentationStyle = .fullScreen
        self.present(bucketController, animated: true)
    }
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBAction func invoices(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDashboard.layer.cornerRadius = 15
        viewDashboard.layer.masksToBounds = false
        viewDashboard.layer.maskedCorners = [.layerMinXMinYCorner , .layerMaxXMinYCorner]
    }
    
    @IBAction func showHistroy(_ sender: Any) {
        let dashboard = UIStoryboard(name: "Dashboard", bundle: nil)
        if let historyVC = dashboard.instantiateViewController(withIdentifier: "HistoryViewController") as? UINavigationController{
            historyVC.modalPresentationStyle = .fullScreen
            self.present(historyVC, animated: true)
        }
    }
    

    @IBAction func searchVC(_ sender: Any) {
        let dashboard = UIStoryboard(name: "Dashboard", bundle: nil)
        let searchVC = dashboard.instantiateViewController(withIdentifier: "SearchViewController")
        searchVC.modalPresentationStyle = .fullScreen
        self.present(searchVC, animated: true)
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
        if let urlString = UserSettings.shared.userImage, let url = URL(string: urlString) {
            userImage.af.setImage(withURL: url)
        } else {
            userImage.image = createInitialImage(name: UserSettings.shared.userName)
        }
        userName.text = UserSettings.shared.userName
        let history = HistoryManager.shared.getHistory()
        self.tableHistory.dataSource = self
        self.tableHistory.delegate = self
        self.listData = history
        if history.count > 0 {
            self.tableHistory.reloadData()
        }
    }
    
}
