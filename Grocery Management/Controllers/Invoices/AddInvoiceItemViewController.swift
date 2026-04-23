//
//  AddInvoiceItemViewController.swift
//  Grocery Management
//
//  Created by mac on 15/05/2025.
//

import UIKit
import ProgressHUD

class AddInvoiceItemViewController: UIViewController {

    var isEditingItem : Bool? = nil
    var listData : Datum? = nil
    var invoiceID : Int? = nil
    
    @IBOutlet weak var btnAddInvoice : UIButton!
    @IBOutlet weak var tf_unit: UITextField!
    @IBOutlet weak var buttonSubtract: UIButton!
    @IBOutlet weak var buttonPlus: UIButton!
    @IBOutlet weak var lbl_ItemCount: UILabel!
    @IBOutlet weak var tf_itemName: UITextField!
    @IBOutlet weak var tf_price: UITextField!
    
    var itmQty : Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add New Item"
        self.setupNavigationBackButton(){
            self.navigationController?.popViewController(animated: true)
        }
        if let isEditingItem = self.isEditingItem , isEditingItem{
            self.btnAddInvoice.setTitle("Save", for: .normal)
            self.btnAddInvoice.setImage(nil, for: .normal)
            self.title = "Edit Item"
            setupData()
        }
    }
    func setupData(){
        self.tf_itemName.text = self.listData?.name
        self.tf_unit.text = self.listData?.unit
//        self.tf_instructions.text = self.listData?.description
        self.lbl_ItemCount.text = String(self.listData?.quantity ?? 0)
        self.itmQty = self.listData?.quantity ?? 0
//        self.tf_variation.text = self.listData?.variation ?? ""
        self.tf_price.text = String(self.listData?.price ?? 0)
    }
    
    @IBAction func actionRemoveItem(_ sender: Any) {
        if(itmQty > 1){
            itmQty -= 1
        }
        lbl_ItemCount.text = String(itmQty)
    }
    
    @IBAction func actionAddItem(_ sender: Any) {
       
            itmQty += 1
        lbl_ItemCount.text = String(itmQty)
    }
    @IBAction func AddInvoiceItem(_ sender: Any) {
        if let itemName = tf_itemName.text?.trimmingCharacters(in: [" "]) {
            if itemName.isEmpty{
                showToastAlert(message: "Name must not be empty")
                return
            }
            
            let itemUnit = tf_unit.text?.trimmingCharacters(in: [" "])
           
            ProgressHUD.animate()
            if let isEditingItem = self.isEditingItem , isEditingItem{
                updateInvoiceItem(name: itemName, unit: itemUnit ?? "")
            } else {
                AddInvoiceItem(name : itemName , unit : itemUnit ?? "")
            }
        } else {
            showToastAlert(message: "Name must not be empty")
        }
    }
    func updateInvoiceItem(name: String , unit : String){
        AuthService.updateInvoiceItem(invoiceID: String(self.invoiceID ?? 0) , itemID: String(listData?.id ?? 0), name: name, price: tf_price.text ?? "" , variation: "", unit: unit , quantity: String(itmQty), description: ""){ result in
            switch result {
            case .success(let (response, headers)):
                
                AppLogger.general.info("Update Invoice Item API Success:")
                ProgressHUD.dismiss()
                self.showToastAlert(message: "Item successfully updated") {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                AppLogger.error.error("Update Invoice Item API failed: \(error.localizedDescription)")
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
    func AddInvoiceItem(name : String, unit : String){
        AuthService.addInvoiceItem(invoiceID: String(self.invoiceID ?? 0), variation: "", name: name, price: tf_price.text ?? "", unit: unit, quantity: String(itmQty), description: ""){ result in
            switch result {
            case .success(let (response, headers)):
                
                AppLogger.general.info("Add Invoice Item API Success:")
                ProgressHUD.dismiss()
                self.showToastAlert(message: "Item successfully added") {
                    self.navigationController?.popViewController(animated: true)
                }
               
                
            case .failure(let error):
                AppLogger.error.error("Add Invoice item API failed: \(error.localizedDescription)")
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
