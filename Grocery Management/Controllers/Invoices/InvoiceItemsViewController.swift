//
//  InvoiceItemsViewController.swift
//  Grocery Management
//
//  Created by mac on 15/05/2025.
//

import UIKit
import ProgressHUD
import Vision

struct ScannedItem: Hashable {
    let name: String
    let quantity: Int
    let price: Double
}

struct DeletedItems: Hashable {
    let id: Int
    let _destroy: Bool
}


class InvoiceItemsViewController: UIViewController , UITextFieldDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var invoiceTitle: String
    var invoiceID : Int
    var invoiceColor : String
    var invoiceIcon : String
    var invoicesListData : [ListData]
    let refreshControl = UIRefreshControl()
    
    var selectedIndexPaths : [IndexPath] = []
    
    @IBOutlet weak var viewNoItems: UIView!
    @IBOutlet weak var viewAddButtons: UIView!
    var itemsData : [Datum]?
    var filteredItems : [Datum]? = nil
    var isSearching = false
    var scannedItems: Set<ScannedItem> = []
    var searchDebounceTimer : Timer?
    
    @IBOutlet weak var lbl_noResult: UILabel!
    @IBOutlet weak var tableInvoiceItems: UITableView!
    @IBOutlet weak var tf_search: UITextField!
    
    init(invoiceTitle: String , invoiceID : Int , invoiceColor : String , invoiceIcon : String , invoicesListData : [ListData]) {
        self.invoiceTitle = invoiceTitle
        self.invoiceID = invoiceID
        self.invoiceIcon = invoiceIcon
        self.invoiceColor = invoiceColor
        self.invoicesListData = invoicesListData
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.invoiceTitle = ""
        self.invoiceID = 0
        self.invoiceColor = ""
        self.invoiceIcon = ""
        self.invoicesListData = []
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = invoiceTitle
        
        self.tf_search.delegate = self
        self.tf_search.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.setupNavigationBackButton(){
            self.dismiss(animated: true)
        }
        viewNoItems.isHidden = true
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableInvoiceItems.refreshControl = refreshControl
        setupRightButton()
        setupToolbar()
    }

    func setupToolbar() {
        let deleteItem = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteSelectedItems))
        deleteItem.tintColor = UIColor.init(named: "buttonbg")
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbarItems = [flexible, deleteItem, flexible]
    }
    
    @objc func deleteSelectedItems(){
        self.showAlertAction(title: "", message: "Delete selected items?" , canShowCancel: true){
            self.tableInvoiceItems.isEditing = false
            self.updateToolbarVisibility()
            self.setupRightButton()
            self.deleteItems()
        }
    }
    
    func deleteItems(){
        let deletedItems: [DeletedItems] = selectedIndexPaths.compactMap { indexPath in
            guard let item = itemsData?[indexPath.row], let id = item.id else {
                return nil
            }
            return DeletedItems(id: id, _destroy: true)
        }
        AuthService.deleteSelectedItem(listID: String(invoiceID), items: deletedItems){
            result in
            
            switch result{
            case .success((let response,_)):
                print(response.message)
                self.getInvoiceItems()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    override func viewWillAppear(_ aniamted : Bool){
        super.viewWillAppear(aniamted)
        ProgressHUD.animate()
        getInvoiceItems()
        self.navigationController?.isToolbarHidden = true
    }
    
    
    @IBAction func addItemWithAI(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in self.openCamera() })
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in self.openGallery() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
        
    }
    
    func openCamera() {
           guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
           let picker = UIImagePickerController()
           picker.delegate = self
           picker.sourceType = .camera
           present(picker, animated: true)
       }

       func openGallery() {
           guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
           let picker = UIImagePickerController()
           picker.delegate = self
           picker.sourceType = .photoLibrary
           present(picker, animated: true)
       }

    @objc func refreshData() {
        
        ProgressHUD.animate()
        self.tf_search.text = ""
        getInvoiceItems()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshControl.endRefreshing()
        }
    }
    
       // MARK: - Image Picker Delegate
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        ProgressHUD.animate()
           if let image = info[.originalImage] as? UIImage {
//               imageView?.image = image
               recognizeText(from: image)
           }
           picker.dismiss(animated: true)
       }
    
    func recognizeText(from image: UIImage) {
           guard let cgImage = image.cgImage else { return }

           let request = VNRecognizeTextRequest { request, error in
               guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
               let lines = observations.compactMap { $0.topCandidates(1).first?.string }
               self.scannedItems = self.parseLines(lines)
               ProgressHUD.dismiss()
               print("Scanned Items: \(self.scannedItems)")
               
               self.addItemsinInvoice(items: Array(self.scannedItems))
               
           }

           request.recognitionLevel = .accurate
           request.usesLanguageCorrection = true

           let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
           DispatchQueue.global(qos: .userInitiated).async {
               try? handler.perform([request])
           }
       }
    func parseLines(_ lines: [String]) -> Set<ScannedItem> {
            var items: [String] = []
            var quantities: [Int] = []
            var prices: [Double] = []

            var currentSection: String?

            for line in lines {
                let clean = line.trimmingCharacters(in: .whitespacesAndNewlines)

                if clean.lowercased().contains("name") {
                    currentSection = "name"
                    continue
                } else if clean.lowercased().contains("qty") {
                    currentSection = "qty"
                    continue
                } else if clean.lowercased().contains("price") {
                    currentSection = "price"
                    continue
                }

                switch currentSection {
                case "name":
                    items.append(clean)
                case "qty":
                    if let q = Int(clean) { quantities.append(q) }
                case "price":
                    let cleaned = clean.filter { $0.isNumber || $0 == "." }
                    if let price = Double(cleaned) {
                        prices.append(price)
                    }
                default:
                    break
                }
            }

            let count = min(items.count, quantities.count, prices.count)
            var result: Set<ScannedItem> = []

            for i in 0..<count {
                let item = ScannedItem(name: items[i], quantity: quantities[i], price: prices[i])
                result.insert(item)
            }

            return result
        }

//    func parseLine(_ line: String) -> ScannedItem? {
//        let pattern = #"^(.*?)[\s\t]+(\d+)(?:\s*[xX\u00D7]\s*)?(\d+)?[\s\t]+(\d+)$"#
//        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
//        
//        let nsLine = line as NSString
//        guard let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: nsLine.length)) else {
//            return nil
//        }
//        
//        let name = nsLine.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespaces)
//        let quantityString = nsLine.substring(with: match.range(at: 2))
//        let totalPriceString = nsLine.substring(with: match.range(at: 4))
//        
//        guard let quantity = Int(quantityString), let totalPrice = Int(totalPriceString) else { return nil }
//        
//        return ScannedItem(name: name, quantity: quantity, price: String(totalPrice))
//    }
    
    func addItemsinInvoice(items : [ScannedItem]){
        checkInternetConnection { isConnected in
            if !isConnected {
                self.showNoInternetAlert()
                return
            }
        }
        AuthService.createAIInvoiceList(invoiceID: String(self.invoiceID), userID: UserSettings.shared.id, name: invoiceTitle, color: invoiceColor, icon: invoiceIcon, items: items){ result in
            switch result{
            case .success((let response,_)):
                print(response.message ?? "")
                self.getInvoiceItems()
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }

    @IBAction func listComparison(_ sender: Any) {
        getListInvoices()
    }
    func getListInvoices(){
        
        let storyboard = UIStoryboard(name: "Invoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CompareInvoiceListVC") as? CompareInvoiceListVC
        if let controller = controller {
            if let sheet = controller.sheetPresentationController {
                sheet.detents = [.medium() ]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 25
            }
            controller.invoicesListData = self.invoicesListData
            controller.onListSelected = { selectedListID in
                ProgressHUD.animate()
               
                DispatchQueue.main.asyncAfter(deadline: .now()+3){
                    ProgressHUD.dismiss()
                    let controller = storyboard.instantiateViewController(identifier: "ComparisonViewController") as? ComparisonViewController
                    if let controller = controller{
                        controller.idListA = self.invoiceID
                        controller.idListB = selectedListID
                        controller.invoicesListData = self.invoicesListData
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            }
            self.present(controller, animated: true)
        }
    }
    @IBAction func AddinvoiceItems(_ sender: Any) {
        openControllerToAddBucketItems()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        searchDebounceTimer?.invalidate()
        
        let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if query.isEmpty {
            isSearching = false
            lbl_noResult.isHidden = true
            filteredItems = itemsData
            tableInvoiceItems.reloadData()
        } else {
            isSearching = true
            
            searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                
                self.filteredItems = self.itemsData?.filter {
                    ($0.name ?? "").lowercased().contains(query.lowercased())
                }
                if self.filteredItems?.count ?? 0 == 0 {
                    lbl_noResult.isHidden = false
                } else {
                    lbl_noResult.isHidden = true
                }
                self.tableInvoiceItems.reloadData()
            }
        }
    }
    
    func setupRightButton(){
        
        let barButtonItem: UIBarButtonItem.SystemItem = tableInvoiceItems.isEditing ? .done : .edit
        let button = UIBarButtonItem(barButtonSystemItem: barButtonItem, target: self, action: #selector(didTapEditIcon))
        button.tintColor = UIColor(named: "buttonbg")
        navigationItem.rightBarButtonItem = button
        
    }
    
    
    @objc func didTapEditIcon() {
        tableInvoiceItems.isEditing.toggle()
        if !tableInvoiceItems.isEditing{
            self.selectedIndexPaths.removeAll()
        }
        setupRightButton()
        
    }
    
   
    func getInvoiceItems(){
        checkInternetConnection { isConnected in
            if !isConnected {
                self.showNoInternetAlert()
                return
            }
        }
        AuthService.getInvoiceItems(bucketID: String(invoiceID), type: "bucket_list"){ [self] result in
            switch result {
            case .success(let (response, _)):
                
                AppLogger.general.info("GetBucketList API Successfully get data:")
                ProgressHUD.dismiss()
                if let itemsData = response.data , itemsData.count > 0{
                    self.itemsData = itemsData
                    viewNoItems.isHidden = true
                    tableInvoiceItems.isHidden = false
                    tableInvoiceItems.delegate = self
                    tableInvoiceItems.dataSource = self
                    tableInvoiceItems.allowsMultipleSelectionDuringEditing = true
                    tableInvoiceItems.reloadData()
                    self.addPlusIconNavBar()
                } else {
                    viewNoItems.isHidden = false
                    tableInvoiceItems.isHidden = true
                    self.viewAddButtons.isHidden = true
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
        self.viewAddButtons.isHidden = false
    }
    
    func openControllerToAddBucketItems(){
        
        
        let board = UIStoryboard(name: "Invoice", bundle: nil)
        if let controller = board.instantiateViewController(identifier: "AddInvoiceItemViewController") as? AddInvoiceItemViewController{
            controller.invoiceID = self.invoiceID
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
extension InvoiceItemsViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching{
            return filteredItems?.count ?? 0
        }
        return itemsData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvoiceItemsTVCell") as! InvoiceItemsTVCell
        var data : Datum? = itemsData?[indexPath.row]
        if isSearching {
            data = filteredItems?[indexPath.row]
        }
        if let data = data
        {
            cell.itemName.text = data.name ?? ""
            cell.item_qty.text = String(data.quantity ?? 0)
            cell.item_price.text = UserSettings.shared.currency + String(data.price ?? 0)
            
        } else {
            cell.itemName.text = ""
            cell.item_qty.text = ""
            cell.item_price.text = ""
        }
//        let cleanedHex = self.invoiceColor.replacingOccurrences(of: "0x", with: "")
//        if let hexInt = Int(cleanedHex, radix: 16) {
//            let color = UIColor(hex: hexInt).withAlphaComponent(0.11)
//            cell.cellView.backgroundColor = color
//        } else {
//            cell.cellView.backgroundColor = UIColor.red.withAlphaComponent(0.11)
//        }
//        cell.cellView.layer.borderColor = UIColor.lightGray.cgColor
//        cell.cellView.layer.borderWidth = 0.22

        cell.cellView.backgroundColor = .white
        return cell
    }
    
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath : IndexPath) {
        self.selectedIndexPaths.append(indexPath)
        if !tableView.isEditing{
            tableView.deselectRow(at: indexPath, animated: false)
        }
        print(self.selectedIndexPaths.count)
        updateToolbarVisibility()
    }
    
    func tableView(_ tableView : UITableView, didDeselectRowAt indexPath : IndexPath) {
        self.selectedIndexPaths.removeAll(where: {
            $0 == indexPath
        })
        updateToolbarVisibility()
    }
    func updateToolbarVisibility() {
        if let selected = tableInvoiceItems.indexPathsForSelectedRows, !selected.isEmpty {
            self.navigationController?.setToolbarHidden(false, animated: true)
        } else {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "") { (_, _, completionHandler) in
            self.deleteRow(at: indexPath) { isDeleted in
                if isDeleted{
                    self.itemsData?.remove(at: indexPath.row)
//                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.showToastAlert(message: "Item deleted")
                    self.getInvoiceItems()
                    completionHandler(true)
                } else {
                    self.showToastAlert(message: "Item cannot be deleted")
                    completionHandler(true)
                }
            }
        }
        
        let editAction = UIContextualAction(style: .normal, title: ""){ (_, _, completionHandler) in
            let board = UIStoryboard(name: "Invoice", bundle: nil)
            if let controller = board.instantiateViewController(identifier: "AddInvoiceItemViewController") as? AddInvoiceItemViewController{
                controller.isEditingItem = true
                controller.title = "Edit Item"
                controller.invoiceID = self.invoiceID
                controller.listData = self.itemsData?[indexPath.row]
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
        AuthService.deleteInvoiceItem(itemID: String(itemsData?[indexPath.row].id ?? 0) , InvoicelistID: String(self.invoiceID)){
            result in
            switch result{
            case .success(let (response , header)):
                return completion(true)
                
            case .failure(let error) :
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
