//
//  StartShoppingViewController.swift
//  Grocery Management
//
//  Created by mac on 04/07/2025.
//

import UIKit
import ProgressHUD

class StartShoppingViewController: UIViewController {
    
    var bucketTitle: String
    var bucketID : Int
    var bucketColor : String
    
    let refreshControl = UIRefreshControl()
    var itemsListData : [Datum]?
    var sharedListData : [SharedList]?
    var filteredItems : [Datum]? = nil
    var isSearching = false
    var isFromHistory = false
    var searchDebounceTimer : Timer?
    
    var unpurchasedItems: [Datum] = []
    var purchasedItems: [Datum] = []
  
    @IBOutlet weak var glowingView: UIView!
    var isSharedBucket : Bool? = false
    @IBOutlet weak var tableBucketItems: UITableView!
    
    
    
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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = bucketTitle
//        self.addFullScreenGlow()
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
        tableBucketItems.sectionHeaderTopPadding = 0
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableBucketItems.refreshControl = refreshControl
    }

    func addFullScreenGlow() {
           let glowLayer = CAShapeLayer()
           glowLayer.frame = view.bounds
 
           let cornerRadius: CGFloat = 54
           let path = UIBezierPath(roundedRect: view.bounds.insetBy(dx: 1, dy: 1), cornerRadius: cornerRadius)
           glowLayer.path = path.cgPath

           glowLayer.lineWidth = 6
           glowLayer.strokeColor = UIColor.red.cgColor
           glowLayer.fillColor = UIColor.clear.cgColor

           glowLayer.shadowColor = UIColor.red.cgColor
           glowLayer.shadowRadius = 10
           glowLayer.shadowOpacity = 1.0
           glowLayer.shadowOffset = .zero

           view.layer.addSublayer(glowLayer)
 
           let animation = CABasicAnimation(keyPath: "opacity")
           animation.fromValue = 1.0
           animation.toValue = 0.2
           animation.duration = 0.5
           animation.autoreverses = true
           animation.repeatCount = .infinity
           glowLayer.add(animation, forKey: "glowAnimation")
       }
    @objc func refreshData() {
        ProgressHUD.animate()
        getBucketItems()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
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
                    tableBucketItems.isHidden = false
                    tableBucketItems.delegate = self
                    tableBucketItems.dataSource = self
                    prepareSections()
                    tableBucketItems.reloadData()
                    self.addPlusIconNavBar()
                } else {
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
    func addPlusIconNavBar() {
        
        let addAction = UIAction(title: "Add", image: UIImage(systemName: "plus")) { _ in
            self.didTapPlus()
        }
        
        
        let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            self.didTapShare()
        }
        
        let editAction = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
            self.tableBucketItems.allowsMultipleSelection = true
            self.tableBucketItems.allowsMultipleSelectionDuringEditing = true
            self.tableBucketItems.isEditing = true
        }
        var childs : [UIAction] = []
        
        if !isSharedBucket!{
            if !isFromHistory {
                childs.append(shareAction)
            }
            childs.append(addAction)
            childs.append(editAction)
            
            
            let menu = UIMenu(title: "", children: [])
            let menuButton = UIBarButtonItem(title: nil, image: UIImage(systemName: "ellipsis.circle"), primaryAction: nil, menu: menu)
            menuButton.tintColor = UIColor(named: "buttonbg")
//            self.navigationItem.rightBarButtonItem = menuButton
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

extension StartShoppingViewController : UITableViewDelegate , UITableViewDataSource{
    
    func prepareSections() {
        if isSearching {
            let filtered = filteredItems ?? []
            unpurchasedItems = filtered.filter { $0.isPurchased == false }
            purchasedItems = filtered.filter { $0.isPurchased == true }
        } else {
            let all = itemsListData ?? []
            unpurchasedItems = all.filter { $0.isPurchased == false }
            purchasedItems = all.filter { $0.isPurchased == true }
            if(unpurchasedItems.count == 0){
                showEndShoppingButton()
            }
        }
    }
    
    func showEndShoppingButton(){
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? unpurchasedItems.count : purchasedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StartShoppingTableViewCell") as! StartShoppingTableViewCell
        
        let data = indexPath.section == 0 ? unpurchasedItems[indexPath.row] : purchasedItems[indexPath.row]
        
        cell.itemName.text = data.name ?? ""
        cell.item_qty.text = String(data.quantity ?? 0)
        cell.item_unit.text = data.unit ?? ""
        cell.item_notes.text = data.description ?? ""
        cell.item_variations.text = data.variation ?? ""
        cell.cellView.backgroundColor = .white
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.init(named: "headerBG")
        headerView.layer.cornerRadius = 10
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = section == 0 ? "🛒 To Buy" : "✅ Purchased"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .darkGray

        headerView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if unpurchasedItems.count == 0
            {
                return 0
            }
        }
        if section == 1 {
            if purchasedItems.count == 0 {
                return 0
            }
        }
        return 40
    }

    func tableView(_ tableView : UITableView, didSelectRowAt indexPath : IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        if indexPath.section == 1 {
            let purchasedAction = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
               
                self.setAsUnPurchased(at : indexPath){ isMarked in
                    if isMarked{
                        self.showToastAlert(message: "Item marked as Unpurchased")
                        self.getBucketItems()
                        completionHandler(true)
                    } else {
                        self.showToastAlert(message: "Item cannot be marked as unpurchased")
                        completionHandler(true)
                    }
                }
                completionHandler(true)
            }
            let purchased = createCircularIconWithBackground(iconName: "ic_purchased_item", bgColor: UIColor(hex: 0xD9F2EF))
            purchasedAction.image = purchased
            purchasedAction.backgroundColor = UIColor.init(hex: 0xB0E4DD)
            
            return UISwipeActionsConfiguration(actions: [purchasedAction])
        }
        let purchasedAction = UIContextualAction(style: .normal, title: "") { (action, view, completionHandler) in
           
            self.setAsPurchased(at : indexPath){ isMarked in
                if isMarked{
                    self.showToastAlert(message: "Item Marked as Purchased")
                    self.getBucketItems()
                    completionHandler(true)
                } else {
                    self.showToastAlert(message: "Item cannot be marked as Purchased")
                    completionHandler(true)
                }
            }
            completionHandler(true)
        }
        let purchased = createCircularIconWithBackground(iconName: "ic_purchased_item", bgColor: UIColor(hex: 0xD9F2EF))
        purchasedAction.image = purchased
        purchasedAction.backgroundColor = UIColor.init(hex: 0xB0E4DD)
        
        return UISwipeActionsConfiguration(actions: [purchasedAction])
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
        let item = indexPath.section == 0 ? unpurchasedItems[indexPath.row] : purchasedItems[indexPath.row]
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
                let data = indexPath.section == 0 ? self.unpurchasedItems[indexPath.row] : self.purchasedItems[indexPath.row]
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
        
        return UISwipeActionsConfiguration(actions: [ ])
    }
    
    func deleteRow(at indexPath : IndexPath , completion: @escaping (Bool) -> Void){
        checkInternetConnection { isConnected in
            if !isConnected {
                self.showNoInternetAlert()
                return completion(false)
            }
        }
        let data = indexPath.section == 0 ? unpurchasedItems[indexPath.row] : purchasedItems[indexPath.row]
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
