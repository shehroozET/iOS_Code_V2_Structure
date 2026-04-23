//
//  AddBucketViewController.swift
//  Grocery Management
//
//  Created by mac on 30/04/2025.
//

import UIKit
import ProgressHUD

struct BucketItem: Codable, Sendable {
    let name: String
    let price: Double
    let quantity: Int
    let unit: String
    let variation : String
    let description: String
}
extension BucketItem {
    func toDict() -> [String: Any] {
        return [
            "name": self.name,
            "price": self.price,
            "quantity": self.quantity,
            "unit": self.unit,
            "variation": self.variation,
            "description": self.description
        ]
    }
}

class AddBucketViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource{
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var iconCollectionView: UICollectionView!
    @IBOutlet weak var tf_bucketName: UITextField!
    
    var isEditingBucket: Bool? = nil
    var isduplicatingBucket: Bool? = nil
    var listData: ListData? = nil
    var allBucketData: [ListData]? = nil
    
    var selectedIndexPathColor : IndexPath? = nil
    var selectedIndexPathIcon : IndexPath? = nil
    
    let itemsInSection = 6
    
    var listColors : [[Int]] = [[0x047C52 , 0x524C8C, 0xFFE200, 0x6E7972 , 0xD23D33 , 0xC1A386],[ 0x64D2FF , 0xFF9F0A , 0x00EA96 , 0xE1289B , 0xBF5AF2 , 0x734230]]
    var listIcons : [[String]] = [["icon_1", "icon_2", "icon_3", "icon_4", "icon_5", "icon_6"],[ "icon_7", "icon_8", "icon_9", "icon_10", "icon_11", "icon_12"],[ "icon_13", "icon_14", "icon_15", "icon_16", "icon_17", "icon_18"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.setupNavigationBackButton(){
            self.navigationController?.popViewController(animated: true)
        }
        
        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        iconCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "iconCell")
        
        
        colorCollectionView.delegate = self
        iconCollectionView.delegate = self
        colorCollectionView.dataSource = self
        iconCollectionView.dataSource = self
        colorCollectionView.reloadData() {
            self.colorCollectionView.reloadData()
        }
        iconCollectionView.reloadData() {
            self.iconCollectionView.reloadData()
        }
        
        if let isEdit = isEditingBucket , isEdit {
            setupUI()
        }
        if let isduplicatingBucket = isduplicatingBucket , isduplicatingBucket{
            
            setupUI()
        }
        
    }
    
    func setupUI(){
        tf_bucketName.text = listData?.name ?? ""
        let listdata = (icon: listData?.iconName ?? "", color:  listData?.color ?? "")
        let result = findColorAndIconIndexPaths(listdata: listdata)

        if let colorIndexPath = result.colorIndexPath {
            self.selectedIndexPathColor = colorIndexPath
            print("Color found at section \(colorIndexPath.section), row \(colorIndexPath.row)")
        }

        if let iconIndexPath = result.iconIndexPath {
            self.selectedIndexPathIcon = iconIndexPath
            print("Icon found at section \(iconIndexPath.section), row \(iconIndexPath.row)")
        }
    }
    func createBucket(items : [BucketItem]){
        ProgressHUD.animate()
        if let userID = TokenManager.shared.userID , let selectedIndexPathColor = self.selectedIndexPathColor , let selectedIndexPathIcon = self.selectedIndexPathIcon{
            let color = listColors[selectedIndexPathColor.section][selectedIndexPathColor.row]
            let icon = listIcons[selectedIndexPathIcon.section][selectedIndexPathIcon.row]
            let hexString = String(format: "0x%06X", color)
            
            AuthService.createBucketList(userID: userID, name: tf_bucketName.text!, color: hexString, icon: icon , items: items){
                result in
                switch result {
                case .success(let (response, _)):
                    if let isSuccesseded = response.success{
                        if isSuccesseded{
                            self.showAlertAction(title: response.message ?? "Bucket List created", message: ""){
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    } else {
                        self.showAlertNoAction(title: "", message: "Something went wrong. Please try again later.")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    ProgressHUD.dismiss()
                }
            }
        }
    }
    func findColorAndIconIndexPaths(listdata: (icon: String, color: String)) -> (colorIndexPath: IndexPath?, iconIndexPath: IndexPath?) {
        
        let hexString = listdata.color.replacingOccurrences(of: "0x", with: "")
        guard let colorInt = Int(hexString, radix: 16) else {
            return (nil, nil)
        }

        var colorIndexPath: IndexPath?
        var iconIndexPath: IndexPath?

        for (section, colors) in listColors.enumerated() {
            for (row, color) in colors.enumerated() {
                if color == colorInt {
                    colorIndexPath = IndexPath(row: row, section: section)
                }
            }
        }
        
        for (section, icons) in listIcons.enumerated() {
            for (row, icon) in icons.enumerated() {
                if icon == listdata.icon {
                    iconIndexPath = IndexPath(row: row, section: section)
                }
            }
        }

        return (colorIndexPath, iconIndexPath)
    }

    @IBAction func saveBucket(_ sender: Any) {
        if let bucket = tf_bucketName.text?.trimmingCharacters(in: [" "]) {
            if bucket.isEmpty{
                showToastAlert(message: "Bucket Name must not be empty")
                return
            }
        }
        if let isduplicatingBucket = self.isduplicatingBucket , isduplicatingBucket{
            let board = UIStoryboard(name: "bucket", bundle: nil)
            let controller = board.instantiateViewController(withIdentifier: "SelectItemsToDuplicateViewController") as? SelectItemsToDuplicateViewController
            if let controller = controller {
                controller.listData = self.allBucketData
                controller.onCreateBucket = { items in
                    let items: [BucketItem] = items.map { item in
                        return BucketItem(
                            name: item.name ?? "",
                            price: item.price ?? 0,
                            quantity: item.quantity ?? 0,
                            unit: item.unit ?? "",
                            variation: item.variation ?? "",
                            description: item.description ?? ""
                        )
                    }
                    self.createBucket(items: items)
                }
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return
        }
        ProgressHUD.animate()
      
        if let userID = TokenManager.shared.userID , let selectedIndexPathColor = self.selectedIndexPathColor , let selectedIndexPathIcon = self.selectedIndexPathIcon{
            let color = listColors[selectedIndexPathColor.section][selectedIndexPathColor.row]
            let icon = listIcons[selectedIndexPathIcon.section][selectedIndexPathIcon.row]
            let hexString = String(format: "0x%06X", color)
            if let isEditingBucket = self.isEditingBucket , isEditingBucket{
                AuthService.updateBucket(bucketID: String(listData?.id ?? 0), userID: userID, name: tf_bucketName.text!, color: hexString , icon: icon){
                    result in
                    switch result {
                    case .success(let (response, _)):
                        if let isSuccesseded = response.success{
                            if isSuccesseded{
                                self.showAlertAction(title: response.message ?? "Bucket List updated", message: ""){
                                    self.navigationController?.popViewController(animated: true)
                                }
                            }
                        } else {
                            self.showAlertNoAction(title: "", message: "Something went wrong. Please try again later.")
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                        ProgressHUD.dismiss()
                    }
                }
            } else {
                let items: [BucketItem] = listData?.items?.map { item in
                    return BucketItem(
                        name: item.name ?? "",
                        price: item.price ?? 0,
                        quantity: item.quantity ?? 0,
                        unit: item.unit ?? "",
                        variation: item.variation ?? "",
                        description: item.description ?? ""
                    )
                } ?? []
                createBucket(items: items)
            }
        } else {
            print( TokenManager.shared.userID as Any)
            
            print( selectedIndexPathColor as Any)
            print( selectedIndexPathIcon as Any)
            ProgressHUD.dismiss()
            self.showToastAlert(message: "Please select the icon and Color")
        }
    }
}

extension AddBucketViewController {
    
    func itemToDict(_ item: ItemsBucket) -> [String: Any] {
        return [
            "id": item.id ?? 0,
            "name": item.name ?? "",
            "price": item.price ?? 0,
            "quantity": item.quantity ?? 0,
            "unit": item.unit ?? "",
            "description": item.description ?? ""
        ]
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == colorCollectionView {
            return listColors.count
        } else {
            return listIcons.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCollectionViewCell", for: indexPath) as! colorCollectionViewCell
            cell.color.backgroundColor = UIColor.init(hex: listColors[indexPath.section][indexPath.row])
            let screenWidth = (collectionView.frame.width )
            let collectionViewWidth = (screenWidth - 100)/6
            cell.color_view.widthAnchor.constraint(equalToConstant: collectionViewWidth).isActive = true
            let isSelected = (indexPath == selectedIndexPathColor)
            cell.updateBorder(isSelected: isSelected)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconsCollectionViewCell", for: indexPath) as! iconsCollectionViewCell
            cell.icon_image.image = UIImage(named: listIcons[indexPath.section][indexPath.row])
            let screenWidth = (collectionView.frame.width )
            let collectionViewWidth = (screenWidth - 100)/6
            cell.icon_image.widthAnchor.constraint(equalToConstant: collectionViewWidth).isActive = true
            let isSelected = (indexPath == selectedIndexPathIcon)
            cell.updateBorder(isSelected: isSelected)
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        AppLogger.debug.debug("")
        if collectionView == colorCollectionView {
            selectedIndexPathColor = indexPath
            
        } else {
            selectedIndexPathIcon = indexPath
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        collectionView.reloadData()
    }
   
    

}
