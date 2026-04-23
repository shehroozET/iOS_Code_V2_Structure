//
//  SearchViewController.swift
//  Grocery Management
//
//  Created by mac on 30/04/2025.
//

import UIKit
import ProgressHUD

class SearchViewController: UIViewController,UISearchBarDelegate, UITextFieldDelegate , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var lblResultFound: UILabel!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var capsuleInvoices: UIButton!
    @IBOutlet weak var capsuleBucketList: UIButton!
    @IBOutlet weak var capsuleAll: UIButton!
    
    @IBOutlet weak var viewNoResult: UIView!
    @IBOutlet weak var tableResult: UITableView!
    var searchDebounceTimer : Timer?
    var isSearching = false
    var searchData : [GSearchData]?
    var filterType = ""
    
    override func viewWillAppear(_ animated : Bool){
        super.viewWillAppear(animated)
        filterSearchResult(text: self.searchTF.text ?? "")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        self.title = "Search"
        self.capsuleAll.layer.cornerRadius = self.capsuleAll.frame.height/2
        self.capsuleBucketList.layer.cornerRadius = self.capsuleAll.frame.height/2
        self.capsuleInvoices.layer.cornerRadius = self.capsuleAll.frame.height/2
        self.selecteCapsule(buttons: [capsuleAll , capsuleInvoices , capsuleBucketList], selectedButton: capsuleAll)
        self.searchTF.delegate = self
        
        self.searchTF.becomeFirstResponder()
        
        adjustButtonText(myButton: capsuleAll)
        adjustButtonText(myButton: capsuleInvoices)
        adjustButtonText(myButton: capsuleBucketList)
    
        self.setupNavigationBackButton {
            self.navigationController?.dismiss(animated: true)
        }
       
       
        self.searchTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.view.layoutIfNeeded()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        capsuleAll.titleLabel?.adjustsFontSizeToFitWidth = true
        capsuleInvoices.titleLabel?.adjustsFontSizeToFitWidth = true
        capsuleBucketList.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    func adjustButtonText(myButton : UIButton){
        myButton.titleLabel?.adjustsFontSizeToFitWidth = true
        myButton.titleLabel?.minimumScaleFactor = 0.1
        myButton.titleLabel?.numberOfLines = 1
        myButton.titleLabel?.lineBreakMode = .byClipping
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        searchDebounceTimer?.invalidate()
        
        let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1.1, repeats: false) {  _ in
            if query.isEmpty {
                self.isSearching = false
                // show empty view
                
                self.filterSearchResult(text: self.searchTF.text ?? "")
            } else {
                self.isSearching = true
                
                self.filterSearchResult(text: self.searchTF.text ?? "")
        
            }
        }
    }
    
    func selecteCapsule(buttons : [UIButton] , selectedButton : UIButton){
        for button in buttons {
            if(button == selectedButton){
                button.backgroundColor = UIColor(named: "CapsuleBG")
                button.layer.borderWidth = 0
                button.tintColor = .white
                
            } else {
                button.backgroundColor = .clear
                button.layer.borderColor = UIColor(named: "borderColor")?.cgColor
                button.layer.borderWidth = 1.4
                button.tintColor = .init(named: "textColor")
                
            }
        }
    }
   
    @IBAction func allSearchSelection(_ sender: Any) {
        filterType = ""
        self.selecteCapsule(buttons: [capsuleAll , capsuleInvoices , capsuleBucketList], selectedButton: capsuleAll)
        filterSearchResult(text: self.searchTF.text ?? "")
       
    }
    @IBAction func invoiceSelection(_ sender: Any) {
        filterType = "grocery_invoice"
        self.selecteCapsule(buttons: [capsuleAll , capsuleInvoices , capsuleBucketList], selectedButton: capsuleInvoices)
        filterSearchResult(text: self.searchTF.text ?? "")
        
    }
    
    @IBAction func bucketlistSelection(_ sender: Any) {
        filterType = "bucket_list"
        self.selecteCapsule(buttons: [capsuleAll , capsuleInvoices , capsuleBucketList], selectedButton: capsuleBucketList)
        filterSearchResult(text: self.searchTF.text ?? "")
        
    }
    func filterSearchResult(text : String){
        ProgressHUD.animate()
        AuthService.globalSearch(filterType: filterType, searchName: text) { result in
            switch result {
            case .success(let (response, _)):
                AppLogger.general.info("Search Successfull: Global Search API")
               
                self.tableResult.isHidden = false
                self.searchData = response.data
                
                self.tableResult.delegate = self
                self.tableResult.dataSource  = self
                if let data = response.data , data.count > 0{
                    self.lblResultFound.text = "\(data.count) found"
                    self.viewNoResult.isHidden = true
                    self.tableResult.isHidden = false
                } else {
                    self.lblResultFound.text = "0 found"
                    self.viewNoResult.isHidden = false
                    self.tableResult.isHidden = true
                }
               
                self.tableResult.reloadData {
                    ProgressHUD.dismiss()
                }
            case .failure(let error):
                AppLogger.error.error("Global Search failed: \(error.localizedDescription)")
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
extension SearchViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GlobalSearchTableViewCell") as! GlobalSearchTableViewCell
        
        var title: String?
        var totalItems: Int = 0
        var dateCreated: String?
        var itemType: String?
        var color : String?
        var iconName : String?
        
        if let item = searchData?[safe : indexPath.row] {
            title = item.name
            totalItems = item.items?.count ?? 0
            dateCreated = item.createdAt
            itemType = item.item_type == "BucketList" ? "Bucket" : "Invoice"
            color = item.color
            iconName = item.iconName
        }
        
        cell.title.text = title
        cell.totalItems.text = "Total items : \(totalItems)"
        cell.dateCreated.text =  getDateInString(date: dateCreated ?? "")
        cell.itemType.text =  itemType
        if let colorHex = color{
            let cleanedHex = colorHex.replacingOccurrences(of: "0x", with: "")
            if let hexInt = Int(cleanedHex, radix: 16) {
                let color = UIColor(hex: hexInt).withAlphaComponent(0.12)
                cell.viewCell.backgroundColor = color
            } else {
                cell.viewCell.backgroundColor = UIColor.red.withAlphaComponent(0.12)
            }
        }
        if let iconName = iconName{
            cell.iv_item.image = UIImage(named: iconName) ?? UIImage(named: "icon_1")
        }
        return cell
    }
    
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath : IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let type = searchData?[safe : indexPath.row]?.item_type{
            if type == "BucketList"{
                let board = UIStoryboard(name: "bucket", bundle: nil)
                let controller = board.instantiateViewController(identifier: "BucketItemsViewController") as! BucketItemsViewController
                controller.bucketTitle = searchData?[indexPath.row].name ?? "No name"
                controller.bucketID = searchData?[indexPath.row].id ?? 0
                controller.isSharedBucket = searchData?[indexPath.row].ownership == "shared" ? true : false
                BucketListManager.shared.sharedListData = self.searchData?[indexPath.row].shareList ?? []
                controller.sharedListData = searchData?[indexPath.row].shareList ?? []
                controller.bucketColor = searchData?[indexPath.row].color ?? ""
                self.navigationController?.pushViewController(controller, animated: true)
            }
            if type == "GroceryInvoice"{
                let board = UIStoryboard(name: "Invoice", bundle: nil)
                
                if let controller = board.instantiateViewController(identifier: "InvoiceItemsViewController") as? UINavigationController ,
                   let invoiceItemsVC = controller.topViewController as? InvoiceItemsViewController {
                    invoiceItemsVC.invoiceTitle = searchData?[indexPath.row].name ?? "No name"
                    invoiceItemsVC.invoiceID = searchData?[indexPath.row].id ?? 0
                    invoiceItemsVC.invoiceColor = searchData?[indexPath.row].color ?? ""
//                    invoiceItemsVC.invoicesListData = searchData ?? []
                    invoiceItemsVC.invoiceIcon = searchData?[indexPath.row].iconName ?? ""
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: true)
                }
            }
        }
    }
}
