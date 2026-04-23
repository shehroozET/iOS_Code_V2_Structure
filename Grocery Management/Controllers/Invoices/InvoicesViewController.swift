//
//  InvoicesViewController.swift
//  Grocery Management
//
//  Created by mac on 29/04/2025.
//

import UIKit
import ProgressHUD
import Vision

class InvoicesViewController: UIViewController , UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate{

    
    @IBOutlet weak var viewNoInvoices: UIView!
    var listData : [ListData]?
  
    @IBOutlet weak var viewFilterReset: UIView!
    @IBOutlet weak var btnAddInvoice: UIButton!
    @IBOutlet weak var iv_filters: UIImageView!
    @IBOutlet weak var tableInvoice: UITableView!
    @IBOutlet weak var tf_search: UITextField!
    
    let refreshControl = UIRefreshControl()
    var scannedItems: Set<ScannedItem> = []
    var isFilterApplied = false
    var isSearching = false
    var startDate = ""
    var endDate = ""
    var searchDebounceTimer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.largeContentTitle = "Grocery Invoices"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        // Do any additional setup after loading the view.
        self.tf_search.delegate = self
        self.tf_search.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        viewNoInvoices.isHidden = true
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableInvoice.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ aniamted : Bool){
        super.viewWillAppear(aniamted)
        ProgressHUD.animate()
        if isFilterApplied{
            self.viewFilterReset.isHidden = false
            self.getSearchData(startDate: self.startDate, endDate: self.endDate)
        } else {
            self.viewFilterReset.isHidden = true
            getInvoices()
        }
    }
    
    @objc func refreshData() {
        ProgressHUD.animate()
        if isFilterApplied{
            self.viewFilterReset.isHidden = false
            self.getSearchData(startDate: self.startDate, endDate: self.endDate)
        } else {
            self.viewFilterReset.isHidden = true
            getInvoices()
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
                self.getInvoices()
            } else {
                self.isSearching = true
                
                self.getSearchData(startDate: self.startDate, endDate: self.endDate)
                
                self.tableInvoice.reloadData()
            }
        }
    }
    func getInvoices(){
        checkInternetConnection { isConnected in
            if !isConnected {
                self.showNoInternetAlert()
                return
            }
        }
        AuthService.getInvoiceList() { [self] result in
            switch result {
            case .success(let (response, _)):
                
                AppLogger.general.info("GetInvoiceList API Successfully get data:")
                ProgressHUD.dismiss()
                if let listData = response.data , listData.count > 0{
                    self.listData = listData
                    viewNoInvoices.isHidden = true
                    tableInvoice.isHidden = false
                    tableInvoice.delegate = self
                    tableInvoice.dataSource = self
                    tableInvoice.reloadData()
                    iv_filters.image = UIImage(named: "ic_nofilters")
                    self.setupPlusMenu()
                } else {
                    viewNoInvoices.isHidden = false
                    tableInvoice.isHidden = true
                }
                
            case .failure(let error):
                AppLogger.error.error("GetInvoiceList API failed: \(error.localizedDescription)")
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
    func getSearchData(startDate : String? = "" , endDate : String? = ""){
        checkInternetConnection { isConnected in
            if !isConnected {
                self.showNoInternetAlert()
                return
            }
        }
        ProgressHUD.animate()
        AuthService.searchInvoice(filterType: "grocery_invoice", searchName: self.tf_search.text ?? "", startDate: startDate ?? "", endDate: endDate ?? "") { [self] result in
            switch result {
            case .success(let (response, _)):
                
                AppLogger.general.info("Search Invoice API Successfully get data:")
                ProgressHUD.dismiss()
                if isFilterApplied {
                    iv_filters.image = UIImage(named: "ic_filters")
                }
                if let listData = response.data , listData.count > 0{
                    self.listData = listData
                    viewNoInvoices.isHidden = true
                    tableInvoice.isHidden = false
                    tableInvoice.delegate = self
                    tableInvoice.dataSource = self
                    tableInvoice.reloadData()
                    self.setupPlusMenu()
                } else {
                    if isFilterApplied || isSearching { btnAddInvoice.isHidden = true }
                    else { btnAddInvoice.isHidden = false}
                    viewNoInvoices.isHidden = false
                    tableInvoice.isHidden = true
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
    
    func setupPlusMenu() {
        let addItem = UIAction(title: "Add Item", image: UIImage(systemName: "plus")) { _ in
            self.openControllerToAddInvoice()
        }

        let addWithAI = UIAction(title: "Add with AI", image: UIImage(systemName: "brain.head.profile")) { _ in
            self.addWithAITapped()
        }

        let menu = UIMenu(title: "", children: [addItem, addWithAI])
        
        let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"), menu: menu)
        plusButton.tintColor = UIColor(named: "buttonbg")
        navigationItem.rightBarButtonItem = plusButton
    }
    
    func addWithAITapped(){
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

       // MARK: - Image Picker Delegate
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        ProgressHUD.animate()
           if let image = info[.originalImage] as? UIImage {
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


    
    func addItemsinInvoice(items : [ScannedItem]){
        DispatchQueue.main.async{
            self.openControllerToAddInvoice(scannedItems: items)
        }
    }
    
    @IBAction func addInvoice(_ sender: Any) {
        openControllerToAddInvoice()
    }
    
    @IBAction func resetfilters(_ sender: Any) {
        isFilterApplied = false
        self.viewFilterReset.isHidden = true
        self.startDate = ""
        self.endDate = ""
        self.tf_search.text = ""
        getInvoices()
    }
    @IBAction func applyFilter(_ sender: Any) {
        let storyboard = UIStoryboard(name: "bucket", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "BucketFiltersViewController") as? BucketFiltersViewController
        if let controller = controller {
            if let sheet = controller.sheetPresentationController {
                sheet.detents = [/*.medium(), .large() , */.custom(resolver: { _ in return 300 })]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 25
            }
            controller.startDate = self.startDate
            controller.endDate = self.endDate
            controller.isFromInvoice = true
            controller.onApplyFilters = { startDate, endDate , bucket_type in
                self.startDate = startDate ?? ""
                self.endDate = endDate ?? ""
                if self.startDate.count > 5 && self.endDate.count > 5{
                    self.isFilterApplied = true
                    self.viewFilterReset.isHidden = false
                    self.getSearchData(startDate: startDate, endDate: endDate)
                } else {
                    self.viewFilterReset.isHidden = true
                    self.isFilterApplied = false
                    self.getInvoices()
                }
            }
            
            self.present(controller, animated: true)
        }
    }
    
    func openControllerToAddInvoice(scannedItems : [ScannedItem]? = nil){
        let board = UIStoryboard(name: "Invoice", bundle: nil)
        if let controller = board.instantiateViewController(identifier: "AddInvoiceViewController") as? UINavigationController ,
           let addInvoiceVC = controller.topViewController as? AddInvoiceViewController {
            addInvoiceVC.scannedItems = scannedItems
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }
    }
    
}
extension InvoicesViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableInvoiceCell") as! tableInvoiceCell
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
        
        let board = UIStoryboard(name: "Invoice", bundle: nil)
       
        
        if let controller = board.instantiateViewController(identifier: "InvoiceItemsViewController") as? UINavigationController ,
           let invoiceItemsVC = controller.topViewController as? InvoiceItemsViewController {
            invoiceItemsVC.invoiceTitle = listData?[indexPath.row].name ?? "No name"
            invoiceItemsVC.invoiceID = listData?[indexPath.row].id ?? 0
            invoiceItemsVC.invoiceColor = listData?[indexPath.row].color ?? ""
            invoiceItemsVC.invoicesListData = listData ?? []
            invoiceItemsVC.invoiceIcon = listData?[indexPath.row].iconName ?? ""
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "") { (_, _, completionHandler) in
            self.deleteRow(at: indexPath) { isDeleted in
                if(isDeleted){
                self.listData?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.showToastAlert(message: "Invoice deleted")
                completionHandler(true)
                } else {
                    self.showToastAlert(message: "List cannot be deleted")
                    completionHandler(true)
                }
            }
        }
        
        let editAction = UIContextualAction(style: .normal, title: ""){ (_, _, completionHandler) in
            let board = UIStoryboard(name: "Invoice", bundle: nil)
            
            if let controller = board.instantiateViewController(identifier: "AddInvoiceViewController") as? UINavigationController ,
               let addInvoiceVC = controller.topViewController as? AddInvoiceViewController {
                addInvoiceVC.isEditingInvoice = true
                addInvoiceVC.title = "Edit Invoice"
                addInvoiceVC.listData = self.listData?[indexPath.row]
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true)
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
        AuthService.deleteInvoice(invoiceID: String(listData?[indexPath.row].id ?? 0)){
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
