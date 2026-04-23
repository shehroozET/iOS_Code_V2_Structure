//
//  SelectItemsToDuplicateViewController.swift
//  Grocery Management
//
//  Created by mac on 04/07/2025.
//

import UIKit

class SelectItemsToDuplicateViewController: UIViewController {
    
    var onCreateBucket: ((_ items : [ItemsBucket]) -> Void)?
    
    var listData: [ListData]? = nil
    @IBOutlet weak var listItems : UITableView!
    
    var selectedItems : [ItemsBucket] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.listItems.delegate = self
        self.listItems.dataSource = self
        self.listItems.reloadData(){
            self.listItems.isEditing = true
        }
         listItems.sectionHeaderTopPadding = 0
        self.title = "select items"
        self.setupNavigationBackButton {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func createBucket(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        onCreateBucket?(selectedItems)
    }
}
extension SelectItemsToDuplicateViewController : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.init(named: "headerBG")
        headerView.layer.cornerRadius = 10
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.listData?[section].name
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray

        headerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if listData?[section].items?.count ?? 0 > 0 {
            return 40
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.listData?[section].items?.count ?? 0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return listData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectItemsToDuplicateTableViewCell") as! SelectItemsToDuplicateTableViewCell
        if let data =  listData?[indexPath.section].items?[indexPath.row]{
            
            cell.itemName.text = data.name ?? ""
            cell.item_qty.text = String(data.quantity ?? 0)
            cell.item_unit.text = data.unit ?? ""
            cell.item_notes.text = data.description ?? ""
            cell.item_variations.text = data.variation ?? ""
            cell.cellView.backgroundColor = .white
        }
        return cell
    }
    
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath : IndexPath) {
        if let item = listData?[indexPath.section].items?[indexPath.row]{
            self.selectedItems.append(item)
            print(self.selectedItems.count)
        }
        
    }
    
    func tableView(_ tableView : UITableView, didDeselectRowAt indexPath : IndexPath) {
        self.selectedItems.removeAll(where: {
            if let item = listData?[indexPath.section].items?[indexPath.row]{
                if ($0.id == item.id){
                    return true
                }
            }
            return false
        })
       
    }
    
}
