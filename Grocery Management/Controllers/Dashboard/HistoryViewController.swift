//
//  ListViewController.swift
//  Grocery Management
//
//  Created by mac on 07/04/2025.
//

import UIKit

class HistoryViewController : UIViewController , UITableViewDelegate , UITableViewDataSource {
    
    @IBOutlet weak var tableHistory : UITableView!
    
    var listData : [HistoryItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBackButton {
            self.navigationController?.dismiss(animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        let history = HistoryManager.shared.getHistory()
        self.tableHistory.dataSource = self
        self.tableHistory.delegate = self
        self.listData = history
        if history.count > 0 {
            self.tableHistory.reloadData()
        }
    }
    
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
            itemsController.sharedListData = data.shareList
            itemsController.isFromHistory = true
            itemsController.bucketColor = data.color

            let bucketListVC = board.instantiateViewController(withIdentifier: "BucketListViewController") as! UINavigationController
           
            bucketListVC.viewControllers = [ itemsController]

            bucketListVC.modalPresentationStyle = .fullScreen
            self.present(bucketListVC, animated: true)
            
        }
    }
    
    
}
