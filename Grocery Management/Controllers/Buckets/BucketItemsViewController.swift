//
//  BucketItemsViewController.swift
//  Grocery Management
//
//  Created by mac on 01/05/2025.
//

import UIKit
import ProgressHUD

class BucketItemsViewController: UIViewController , UITextFieldDelegate {
    var bucketTitle: String
    var bucketID : Int
    var bucketColor : String
    
    @IBOutlet weak var viewNoItems: UIView!
    let refreshControl = UIRefreshControl()
    var itemsListData : [Datum]?
    var sharedListData : [SharedList]?
    var filteredItems : [Datum]? = nil
    var isSearching = false
    var isFromHistory = false
    var searchDebounceTimer : Timer?
    
    var selectedIndexPaths : [IndexPath] = []
    
    var bucketItems: [Datum] = []
  
    var isSharedBucket : Bool? = false
    @IBOutlet weak var lbl_noresult: UILabel!
    @IBOutlet weak var tableBucketItems: UITableView!
    @IBOutlet weak var tf_search: UITextField!
    
     
    init(bucketTitle: String , bucketID : Int , bucketColor : String) {
        self.bucketTitle = bucketTitle
        self.bucketID = bucketID
        self.bucketColor = bucketColor
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.bucketTitle = ""
        self.bucketID = 0
        self.bucketColor = ""
        super.init(coder: coder)
    }
    
    @IBAction func AddBucketItems(_ sender: Any) {
        let board = UIStoryboard(name: "bucket", bundle: nil)
        if let controller = board.instantiateViewController(identifier: "AddBucketItemViewController") as? AddBucketItemViewController{
            controller.bucketID = self.bucketID
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = bucketTitle
        self.tf_search.delegate = self
        self.tf_search.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
                
        self.setupNavigationBackButton(){
            if let navigationController = self.navigationController{
                if navigationController.viewControllers[0] is BucketItemsViewController {
                    navigationController.dismiss(animated: true)
                } else {
                    navigationController.popViewController(animated: true)
                }
            } else {
                self.dismiss(animated: true)
            }
        }
        viewNoItems.isHidden = true
        tableBucketItems.sectionHeaderTopPadding = 0
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableBucketItems.refreshControl = refreshControl
        setupToolbar()
        
    }
    func setupToolbar() {
        let deleteItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteSelectedItems))
        deleteItem.tintColor = UIColor.init(named: "buttonbg")
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [flexible, deleteItem, flexible]
    }
    @objc func deleteSelectedItems() {
        self.showAlertAction(title: "", message: "Delete selected items?" , canShowCancel: true){
            self.tableBucketItems.isEditing = false
            self.updateToolbarVisibility()
            self.addNavBarButtons()
            self.deleteItems()
        }
    }
    
    func deleteItems(){
        let deletedItems: [DeletedItems] = selectedIndexPaths.compactMap {
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            indexPath in
            let item = bucketItems[indexPath.row]
            if let id = item.id{
                return DeletedItems(id: id, _destroy: true)
            }
            return nil
        }
        AuthService.deleteSelectedBucketItems(listID: String(bucketID), items: deletedItems){
            result in
            
            switch result{
            case .success((let response,_)):
                print(response.message)
                self.getBucketItems()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func refreshData() {
        ProgressHUD.animate()
        self.tf_search.text = ""
        getBucketItems()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
       
        searchDebounceTimer?.invalidate()
        
        let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if query.isEmpty {
            isSearching = false
            filteredItems = itemsListData
            lbl_noresult.isHidden = true
            prepareSections()
            tableBucketItems.reloadData()
        } else {
            isSearching = true
            searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                
                self.filteredItems = self.itemsListData?.filter {
                    ($0.name ?? "").lowercased().contains(query.lowercased())
                }
                if self.filteredItems?.count ?? 0 == 0 {
                    lbl_noresult.isHidden = false
                } else {
                    lbl_noresult.isHidden = true
                }
                prepareSections()
                self.tableBucketItems.reloadData()
            }
        }
    }
    
    
    override func viewWillAppear(_ aniamted : Bool){
        super.viewWillAppear(aniamted)
        ProgressHUD.animate()
        getBucketItems()
        sharedListData = BucketListManager.shared.sharedListData
    }
    func getBucketItems(){
        checkInternetConnection { isConnected in
            if !isConnected {
                self.showNoInternetAlert()
                return
            }
        }
        AuthService.getBucketItems(bucketID: String(bucketID), type: "bucket_list"){ [self] result in
            switch result {
            case .success(let (response, _)):
                
                AppLogger.general.info("GetBucketList API Successfully get data:")
                ProgressHUD.dismiss()
                if let itemsListData = response.data , itemsListData.count > 0{
                    self.itemsListData = itemsListData
                    viewNoItems.isHidden = true
                    tableBucketItems.isHidden = false
                    tableBucketItems.delegate = self
                    tableBucketItems.dataSource = self
                    prepareSections()
                    tableBucketItems.reloadData()
                    self.addNavBarButtons()
                } else {
                    viewNoItems.isHidden = false
                    tableBucketItems.isHidden = true
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
    func addNavBarButtons() {
        
        let addAction = UIAction(title: "Add", image: UIImage(systemName: "plus")) { _ in
            self.didTapPlus()
        }
        let shoppingAction = UIAction(title: "Start Shopping", image: UIImage(systemName: "bag")) { _ in
            self.didTapStartShopping()
        }
        
        
        let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            self.didTapShare()
        }
        
        let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
            self.tableBucketItems.allowsMultipleSelection = true
            self.tableBucketItems.allowsMultipleSelectionDuringEditing = true
            self.tableBucketItems.isEditing = true
            
           
             
            
            let barButtonItem: UIBarButtonItem.SystemItem = .done
            let button = UIBarButtonItem(barButtonSystemItem: barButtonItem, target: self, action: #selector(self.didTapDoneIcon))
            button.tintColor = UIColor(named: "buttonbg")
            self.navigationItem.rightBarButtonItem = button
        }
        var childs : [UIAction] = []
        
        if !isSharedBucket!{
            if !isFromHistory {
                childs.append(shareAction)
            }
            childs.append(addAction)
            childs.append(editAction)
            childs.append(shoppingAction)
            
            let menu = UIMenu(title: "", children: childs)
            let menuButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: menu)
            menuButton.tintColor = UIColor(named: "buttonbg")
            self.navigationItem.rightBarButtonItem = menuButton
        }
    }
       
    @objc func didTapDoneIcon()
    {
        self.tableBucketItems.isEditing = false
        self.selectedIndexPaths.removeAll()
        addNavBarButtons()
        
    }
    func didTapStartShopping() {
        // controller for shopping
        
        let board = UIStoryboard(name: "bucket", bundle: nil)
        let controller = board.instantiateViewController(identifier: "StartShoppingViewController") as? StartShoppingViewController
        if let controller = controller {
            controller.title = "Start Shopping"
            controller.bucketTitle = self.bucketTitle
            controller.bucketID = self.bucketID
            controller.isFromHistory = self.isFromHistory
            controller.sharedListData = self.sharedListData
            controller.bucketColor = self.bucketColor
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    func didTapPlus() {
        openControllerToAddBucketItems()
    }
    func didTapShare() {
        openContrllerToShareBucket(bucketID : bucketID)
    }
    func openContrllerToShareBucket(bucketID : Int){
        let board = UIStoryboard(name: "bucket", bundle: nil)
        if let controller = board.instantiateViewController(identifier: "ShareBucketViewController") as? ShareBucketViewController{
            controller.bucketID = self.bucketID
            controller.sharedListData = sharedListData
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    func openControllerToAddBucketItems(){
        let board = UIStoryboard(name: "bucket", bundle: nil)
        if let controller = board.instantiateViewController(identifier: "AddBucketItemViewController") as? AddBucketItemViewController{
            controller.bucketID = self.bucketID
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
extension BucketItemsViewController : UITableViewDelegate, UITableViewDataSource{
    
    func prepareSections() {
       
        if isSearching {
            bucketItems = filteredItems ?? []
           
        } else {
            bucketItems = itemsListData ?? []
           
        }
    
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bucketItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BucketItemsTVCell") as! BucketItemsTVCell
        
        let data = bucketItems[indexPath.row]
        
        cell.itemName.text = data.name ?? ""
        cell.item_qty.text = String(data.quantity ?? 0)
        cell.item_unit.text = data.unit ?? ""
        cell.item_notes.text = data.description ?? ""
        cell.item_variations.text = data.variation ?? ""
        cell.cellView.backgroundColor = .white
        
        return cell
    }
    
    
   
    
   func tableView(_ tableView : UITableView, didSelectRowAt indexPath : IndexPath) {
        self.selectedIndexPaths.append(indexPath)
        if (!tableView.isEditing){
            tableView.deselectRow(at: indexPath, animated: false)
          
        }
        updateToolbarVisibility()
       
    }
    func tableView(_ tableView : UITableView, didDeselectRowAt indexPath : IndexPath) {
        
        self.selectedIndexPaths.removeAll(where: {
            $0 == indexPath
        })
        
        updateToolbarVisibility()
    }
    func updateToolbarVisibility() {
        if let selected = self.tableBucketItems.indexPathsForSelectedRows, !selected.isEmpty {
            self.navigationController?.setToolbarHidden(false, animated: true)
        } else {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    

    func setAsPurchased(at indexPath: IndexPath , completion: @escaping (Bool) -> Void){
       
        updateItem(at : indexPath , isPurchased: true){ isCompleted in
            completion(isCompleted)
        }
    }
    func setAsUnPurchased(at indexPath: IndexPath , completion: @escaping (Bool) -> Void){
        updateItem(at : indexPath , isPurchased: false){ isCompleted in
            completion(isCompleted)
        }
       
    }
    func updateItem(at indexPath: IndexPath ,isPurchased : Bool , completion: @escaping (Bool) -> Void){
        let item = self.bucketItems[indexPath.row]
        AuthService.markAsPurchased(itemId: String(item.id ?? 0), is_purchased: isPurchased){
            result in
            switch result{
            case .success( (_ , _)):
                return completion(true)
                
            case .failure(_) :
               return completion(false)
                
            }
        }
    }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 1 || isSharedBucket!{
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "") { (_, _, completionHandler) in
            self.deleteRow(at: indexPath) { isDeleted in
                if isDeleted{
                    self.itemsListData?.remove(at: indexPath.row)
//                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.showToastAlert(message: "Item deleted")
                    self.getBucketItems()
                    completionHandler(true)
                } else {
                    self.showToastAlert(message: "Item cannot be deleted")
                    completionHandler(true)
                }
            }
        }
        
        let editAction = UIContextualAction(style: .normal, title: ""){ (_, _, completionHandler) in
            let board = UIStoryboard(name: "bucket", bundle: nil)
            if let controller = board.instantiateViewController(identifier: "AddBucketItemViewController") as? AddBucketItemViewController{
                controller.isEditingItem = true
                controller.title = "Edit Item"
                controller.bucketID = self.bucketID
                let data = self.bucketItems[indexPath.row]
                controller.selecteditemData = data
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        
        
        let trash = createCircularIconWithBackground(iconName: "ic_delete_list", bgColor: UIColor(hex: 0xFFB5B5))
        deleteAction.image = trash
        deleteAction.backgroundColor = UIColor.init(hex: 0xB0E4DD)
        
        let edit = createCircularIconWithBackground(iconName: "ic_edit_list", bgColor: UIColor(hex: 0xD9F2EF))
        editAction.image = edit
        editAction.backgroundColor = UIColor.init(hex: 0xB0E4DD)
        
        return UISwipeActionsConfiguration(actions: [deleteAction , editAction ])
    }
    
    func deleteRow(at indexPath : IndexPath , completion: @escaping (Bool) -> Void){
        checkInternetConnection { isConnected in
            if !isConnected {
                self.showNoInternetAlert()
                return completion(false)
            }
        }
        let data = self.bucketItems[indexPath.row]
        AuthService.deleteBucketItem(itemID: String(data.id ?? 0) , bucketID: String(self.bucketID)){
            result in
            switch result{
            case .success( (_ , _)):
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
