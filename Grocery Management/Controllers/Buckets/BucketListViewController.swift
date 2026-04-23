//
//  BucketListViewController.swift
//  Grocery Management
//
//  Created by mac on 30/04/2025.
//

import UIKit
import ProgressHUD


class BucketListViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var viewNoBuckets: UIView!
    var listData : [ListData]?
  
    
    @IBOutlet weak var iv_filters: UIImageView!
    @IBOutlet weak var tableBucket: UITableView!
    @IBOutlet weak var tf_search: UITextField!
    @IBOutlet weak var btnAddInvoice: UIButton!
    @IBOutlet weak var viewFilterReset: UIView!
    
    let refreshControl = UIRefreshControl()
    var isFilterApplied = false
    var isSearching = false
    var startDate = ""
    var endDate = ""
    var filterType = "all"
    var searchDebounceTimer : Timer?
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Bucket List"
        
        self.setupNavigationBackButton(){
            self.navigationController?.dismiss(animated: true)
        }
        self.tf_search.delegate = self
        self.tf_search.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        viewNoBuckets.isHidden = true
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableBucket.refreshControl = refreshControl
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .sharedListUpdated, object: nil)
       
    }
    @IBAction func getBucketsDataTab(_ sender: Any) {
        let selectedIndex = (sender as AnyObject).selectedSegmentIndex
        let selectedTitle = (sender as AnyObject).titleForSegment(at: selectedIndex ?? 0) ?? ""
            
           // Add your custom action based on tab
           switch selectedIndex {
           case 0:
               self.filterType = "all"
               getDataBasedonTabs(filterType: self.filterType)
               break
           case 1:
               self.filterType = "own"
               getDataBasedonTabs(filterType: self.filterType)
               break
           case 2:
               self.filterType = "shared"
               getDataBasedonTabs(filterType: self.filterType)
               break
           default:
               break
           }
    }
    @objc func refreshData() {
        // Call your API or reload your data source
        ProgressHUD.animate()
        self.tf_search.text = ""
        if isFilterApplied{
            self.viewFilterReset.isHidden = false
            self.getSearchData(startDate: self.startDate, endDate: self.endDate , filterType: self.filterType)
        } else {
            self.viewFilterReset.isHidden = true
            if filterType == "all"{
                getBuckets()
            } else {
                getSearchData(filterType: self.filterType)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        searchDebounceTimer?.invalidate()
        
        let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) {  _ in
            if query.isEmpty && !self.isFilterApplied{
                self.isSearching = false
                ProgressHUD.animate()
                if self.filterType == "all"{
                    self.getBuckets()
                } else {
                    self.getSearchData(filterType: self.filterType)
                }
            } else {
                self.isSearching = true
                
                self.getSearchData(startDate: self.startDate, endDate: self.endDate , filterType: self.filterType)
                
                self.tableBucket.reloadData()
            }
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .sharedListUpdated, object: nil)
    }
    override func viewWillAppear(_ aniamted : Bool){
        super.viewWillAppear(aniamted)
        ProgressHUD.animate()
        if isFilterApplied{
            self.viewFilterReset.isHidden = false
            self.getSearchData(startDate: self.startDate, endDate: self.endDate , filterType: self.filterType)
        } else {
            self.viewFilterReset.isHidden = true
            if filterType == "all"{
                getBuckets()
            } else {
                getSearchData(filterType: self.filterType)
            }
        }
    }
    func getSearchData(startDate : String? = "" , endDate : String? = "" , filterType : String? = ""){
        checkInternetConnection { isConnected in
            if !isConnected {
                self.showNoInternetAlert()
                return
            }
        }
        ProgressHUD.animate()
        AuthService.searchBucket(filterType: "bucket_list", searchName: self.tf_search.text ?? "", startDate: startDate ?? "", endDate: endDate ?? "" , bucket_type : filterType ?? "") { [self] result in
            switch result {
            case .success(let (response, headers)):
                
                AppLogger.general.info("Search API Successfully get data:")
                ProgressHUD.dismiss()
                if isFilterApplied {
                    iv_filters.image = UIImage(named: "ic_filters")
                }
                if let listData = response.data , listData.count > 0{
                    self.listData = listData
                   
                    viewNoBuckets.isHidden = true
                    tableBucket.isHidden = false
                    tableBucket.delegate = self
                    tableBucket.dataSource = self
                    tableBucket.reloadData()
                    BucketListManager.shared.sharedListData = self.listData?[safe : selectedIndex]?.shareList ?? []
                    NotificationCenter.default.post(name: .apiFetchedData, object: nil)
                    self.addPlusIconNavBar()
                } else {
                    viewNoBuckets.isHidden = false
                    tableBucket.isHidden = true
                }
                
            case .failure(let error):
                AppLogger.error.error("Search API failed: \(error.localizedDescription)")
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
    func getBuckets(){
        checkInternetConnection { isConnected in
            if !isConnected {
                self.showNoInternetAlert()
                return
            }
        }
        
        AuthService.getBucketList() { [self] result in
            switch result {
            case .success(let (response, headers)):
                
                AppLogger.general.info("GetBucketList API Successfully get data:")
                ProgressHUD.dismiss()
                if let listData = response.data , listData.count > 0{
                    self.listData = listData
                    viewNoBuckets.isHidden = true
                    tableBucket.isHidden = false
                    tableBucket.delegate = self
                    tableBucket.dataSource = self
                    tableBucket.reloadData()
                    BucketListManager.shared.sharedListData = self.listData?[selectedIndex].shareList ?? []
                    NotificationCenter.default.post(name: .apiFetchedData, object: nil)
                    iv_filters.image = UIImage(named: "ic_nofilters")
                    self.addPlusIconNavBar()
                } else {
                    if isFilterApplied || isSearching { btnAddInvoice.isHidden = true }
                    else { btnAddInvoice.isHidden = false}
                    viewNoBuckets.isHidden = false
                    tableBucket.isHidden = true
                }
                
            case .failure(let error):
                AppLogger.error.error("GetBucketList API failed: \(error.localizedDescription)")
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
    
    func addPlusIconNavBar(){
        let plusButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapPlus))
        plusButton.tintColor = UIColor(named: "buttonbg")
        
            navigationItem.rightBarButtonItem = plusButton
    }
    @objc func didTapPlus() {
        openControllerToAddBucket()
    }
    
    @IBAction func resetfilters(_ sender: Any) {
        isFilterApplied = false
        self.viewFilterReset.isHidden = true
        self.startDate = ""
        self.endDate = ""
        self.tf_search.text = ""
        if filterType == "all"{
            getBuckets()
        } else {
            getSearchData(filterType: self.filterType)
        }
    }
    
    @IBAction func addBucket(_ sender: Any) {
        openControllerToAddBucket()
    }
    func getDataBasedonTabs(filterType : String){
        self.getSearchData(startDate: startDate, endDate: endDate , filterType : self.filterType)
    }
    @IBAction func applyFilter(_ sender: Any) {
        let storyboard = UIStoryboard(name: "bucket", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "BucketFiltersViewController") as? BucketFiltersViewController
        if let controller = controller {
            if let sheet = controller.sheetPresentationController {
                sheet.detents = [/*.medium(), .large() , */.custom(resolver: { _ in return 200 })]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 25
            }
            controller.startDate = self.startDate
            controller.endDate = self.endDate
            controller.filterType = self.filterType
            controller.onApplyFilters = { startDate, endDate , filterType in
                self.startDate = startDate ?? ""
                self.endDate = endDate ?? ""
                if self.startDate.count > 5 && self.endDate.count > 5{
                    self.isFilterApplied = true
                    self.viewFilterReset.isHidden = false
                    self.getSearchData(startDate: startDate, endDate: endDate , filterType : filterType)
                } else {
                    self.viewFilterReset.isHidden = true
                    self.isFilterApplied = false
                    if self.filterType == "all"{
                        self.getBuckets()
                    } else {
                        self.getSearchData(filterType: self.filterType)
                    }
                    
                }
            }
            
            self.present(controller, animated: true)
        }
    }
    func openControllerToAddBucket(){
        let board = UIStoryboard(name: "bucket", bundle: nil)
        if let controller = board.instantiateViewController(identifier: "AddBucketViewController") as? AddBucketViewController {
            controller.title = "Add New Bucket"
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}
extension BucketListViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableBucketCell") as! tableBucketCell
        if let data = listData?[indexPath.row]
        {
            cell.bucketName.text = data.name
            cell.dateCreated.text = getDateInString(date: data.createdAt ?? "")
            cell.totalItems.text = String(data.items?.count ?? 0)
            if let iconName = data.iconName{
                cell.imageViewBucket.image = UIImage(named: iconName)
            } else {
                cell.imageViewBucket.image = UIImage(named: "icon_1")
            }
            if let colorHex = data.color {
                let cleanedHex = colorHex.replacingOccurrences(of: "0x", with: "")
                if let hexInt = Int(cleanedHex, radix: 16) {
                    let color = UIColor(hex: hexInt).withAlphaComponent(0.22)
                    cell.viewBgCell.backgroundColor = color
                } else {
                    cell.viewBgCell.backgroundColor = UIColor.red.withAlphaComponent(0.22)
                }
            }

        }
        return cell
    }
    
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath : IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let data = listData?[indexPath.row] {
            self.selectedIndex = indexPath.row
            if data.ownership != "shared"
            {
                let clickedItem = HistoryItem(id: data.id ?? 0, name: data.name ?? "", date: data.createdAt ?? "", shareList: data.shareList ?? [], totalItems: data.items?.count ?? 0 , iconName: data.iconName ?? "icon_1" , color: data.color ?? "#111111")
                HistoryManager.shared.addToHistory(clickedItem)
            }
            
            let board = UIStoryboard(name: "bucket", bundle: nil)
            let controller = board.instantiateViewController(identifier: "BucketItemsViewController") as! BucketItemsViewController
            controller.bucketTitle = data.name ?? "No name"
            controller.bucketID = data.id ?? 0
            controller.isSharedBucket = data.ownership == "shared" ? true : false
            controller.sharedListData = data.shareList ?? []
            controller.bucketColor = data.color ?? ""
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        if let data = listData?[indexPath.row] {
            if data.ownership == "shared"
            { return nil }
        }
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "") { (_, _, completionHandler) in
            self.deleteRow(at: indexPath) { isDeleted in
                if(isDeleted){
                self.listData?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.showToastAlert(message: "Bucket deleted")
                completionHandler(true)
                } else {
                    self.showToastAlert(message: "List cannot be deleted")
                    completionHandler(true)
                }
            }
        }
        
        let editAction = UIContextualAction(style: .normal, title: ""){ (_, _, completionHandler) in
            let board = UIStoryboard(name: "bucket", bundle: nil)
            if let controller = board.instantiateViewController(identifier: "AddBucketViewController") as? AddBucketViewController{
                controller.isEditingBucket = true
                controller.title = "Edit Bucket"
                controller.listData = self.listData?[indexPath.row]
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        
        let copyAction = UIContextualAction(style: .normal, title: ""){ (_, _, completionHandler) in
            
            let board = UIStoryboard(name: "bucket", bundle: nil)
            if let controller = board.instantiateViewController(identifier: "AddBucketViewController") as? AddBucketViewController{
                controller.listData = self.listData?[indexPath.row]
                controller.title = "Duplicate Bucket"
                controller.allBucketData = self.listData
                controller.isduplicatingBucket = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        
        let trash = createCircularIconWithBackground(iconName: "ic_delete_list", bgColor: UIColor(hex: 0xFFB5B5))
        deleteAction.image = trash
        deleteAction.backgroundColor = UIColor.init(hex: 0xB0E4DD)
        
        let edit = createCircularIconWithBackground(iconName: "ic_edit_list", bgColor: UIColor(hex: 0xD9F2EF))
        editAction.image = edit
        editAction.backgroundColor = UIColor.init(hex: 0xB0E4DD)
        
        let copy = createCircularIconWithBackground(iconName: "ic_copy_list", bgColor: UIColor(hex: 0xD9F2EF))
        copyAction.image = copy
        copyAction.backgroundColor = UIColor.init(hex: 0xB0E4DD)
        
        
        return UISwipeActionsConfiguration(actions: [deleteAction , editAction , copyAction])
    }
    
    func deleteRow(at indexPath : IndexPath , completion: @escaping (Bool) -> Void){
        checkInternetConnection { isConnected in
            if !isConnected {
                self.showNoInternetAlert()
                return completion(false)
            }
        }
        AuthService.deleteBucket(bucketID: String(listData?[indexPath.row].id ?? 0)){
            result in
            switch result{
            case .success( (_ , _)):
                HistoryManager.shared.deleteFromHistory(by: self.listData?[indexPath.row].id ?? 0)
                return completion(true)
                
            case .failure(_) :
               return completion(false)
                
            }
        }
    }
    func createCircularIconWithBackground(iconName: String, bgColor: UIColor, size: CGFloat = 35) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { context in
            let circleRect = CGRect(x: 0, y: 0, width: size, height: size)
            bgColor.setFill()
            context.cgContext.fillEllipse(in: circleRect)
            
            if let icon = UIImage(named: iconName){
                let iconSize = CGSize(width: size * 0.5, height: size * 0.5)
                let iconOrigin = CGPoint(
                    x: (size - iconSize.width) / 2,
                    y: (size - iconSize.height) / 2
                )
                icon.draw(in: CGRect(origin: iconOrigin, size: iconSize))
            }
        }
    }
    
}
