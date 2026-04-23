//
//  CompareInvoiceListVC.swift
//  Grocery Management
//
//  Created by mac on 20/06/2025.
//

import UIKit

class CompareInvoiceListVC: UIViewController , UITableViewDelegate , UITableViewDataSource{
    @IBOutlet weak var tableInvoices: UITableView!
    
    var invoicesListData : [ListData]?
    
    var onListSelected: ((_ selectedListID: Int?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableInvoices.delegate = self
        self.tableInvoices.dataSource = self
        self.tableInvoices.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        invoicesListData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableItemsInvoiceCell") as! tableItemsInvoiceCell
        if let data = invoicesListData?[indexPath.row]{
            cell.name.text = data.name
            cell.dateCreated.text = self.getDateInString(date: data.createdAt ?? "")
            cell.listItems.text = "\(data.items?.count ?? 0)"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onListSelected?(self.invoicesListData?[indexPath.row].id)
        self.dismiss(animated: true)
    }
    
}
