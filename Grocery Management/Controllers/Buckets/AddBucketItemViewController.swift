//
//  AddBucketItemViewController.swift
//  Grocery Management
//
//  Created by mac on 01/05/2025.
//

import UIKit
import ProgressHUD

class AddBucketItemViewController: UIViewController {
    
    var isEditingItem : Bool? = nil
    var selecteditemData : Datum? = nil
    var bucketID : Int? = nil
    
    @IBOutlet weak var tf_unit_other: UITextField!
    @IBOutlet weak var tf_variation_other: UITextField!
    @IBOutlet weak var dropDownUnit: UIButton!
    @IBOutlet weak var dropDownVariation: UIButton!
    @IBOutlet weak var btnAddBucket: UIButton!
    @IBOutlet weak var tf_unit: UITextField!
    @IBOutlet weak var buttonSubtract: UIButton!
    @IBOutlet weak var buttonPlus: UIButton!
    @IBOutlet weak var lbl_ItemCount: UILabel!
    @IBOutlet weak var tf_itemName: UITextField!
    @IBOutlet weak var tf_instructions: UITextField!
    @IBOutlet weak var tf_variation: UITextField!
    var itmQty : Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add New Item"
        self.setupNavigationBackButton(){
            self.navigationController?.popViewController(animated: true)
        }
        setupUnitMenu()
        setupVariationMenu()
        if let isEditingItem = self.isEditingItem , isEditingItem{
            self.title = "Edit Item"
            self.btnAddBucket.setTitle("Save", for: .normal)
            setupData()
        }
    }
    
    func setupData(){
        self.tf_itemName.text = self.selecteditemData?.name
        self.tf_unit.text = self.selecteditemData?.unit
        self.tf_instructions.text = self.selecteditemData?.description
        self.lbl_ItemCount.text = String(self.selecteditemData?.quantity ?? 0)
        self.itmQty = self.selecteditemData?.quantity ?? 0
        self.tf_variation.text = self.selecteditemData?.variation ?? ""
    }
    func setupUnitMenu() {
        let Kilogram = UIAction(title: "Kilogram") { _ in
            self.setUnitText(text: "Kg")
            self.itmQty = 1 /// Kgs should be in 0.5 Need to add quantity as 0.5
            self.lbl_ItemCount.text = "\(1)"
        }

        let Gram = UIAction(title: "Gram") { _ in
            self.setUnitText(text: "g")
            self.itmQty = 50
            self.lbl_ItemCount.text = "\(50)"
        }

        let Pound = UIAction(title: "Pound") { _ in
            self.setUnitText(text: "lb")
            self.itmQty = 1
            self.lbl_ItemCount.text = "\(1)"
        }
        
        let Liter = UIAction(title: "Liter") { _ in
            self.setUnitText(text: "liter")
            self.itmQty = 1
            self.lbl_ItemCount.text = "\(1)"
        }

        let other = UIAction(title: "Other") { _ in
            self.setUnitText(text: "other")
            self.itmQty = 1
            self.lbl_ItemCount.text = "\(1)"
        }

        let menu = UIMenu(title: "Choose Unit", options: .displayInline, children: [Kilogram, Gram, Pound, Liter, other])
        dropDownUnit.menu = menu
        dropDownUnit.showsMenuAsPrimaryAction = true
    }
    
    func setUnitText(text: String){
        if text == "other"{
            self.tf_unit_other.isHidden = false
        } else {
            self.tf_unit_other.isHidden = true
        }
        self.tf_unit.text = text
    }
    
    func setupVariationMenu() {
        let large = UIAction(title: "Large") { _ in
            self.setVariationText(text: "Large")
        }

        let medium = UIAction(title: "Medium") { _ in
            self.setVariationText(text: "Medium")
        }

        let small = UIAction(title: "Small") { _ in
            self.setVariationText(text: "Small")
        }

        let other = UIAction(title: "Other") { _ in
            self.setVariationText(text: "other")
        }

        let menu = UIMenu(title: "Choose Variation", options: .displayInline, children: [large, medium, small, other])
        dropDownVariation.menu = menu
        dropDownVariation.showsMenuAsPrimaryAction = true
    }
    func setVariationText(text: String){
        if text == "other"{
            self.tf_variation_other.isHidden = false
        } else {
            self.tf_variation_other.isHidden = true
        }
        self.tf_variation.text = text
    }

    @IBAction func actionRemoveItem(_ sender: Any) {
        if  self.tf_unit.text == "g"{
            if(itmQty > 50){
                itmQty -= 50
            }
        }
        else
        if(itmQty > 1){
            itmQty -= 1
        }
        lbl_ItemCount.text = String(itmQty)
    }
    
    @IBAction func actionAddItem(_ sender: Any) {
        if  self.tf_unit.text == "g"{
            itmQty += 50
        } else {
            itmQty += 1
        }
        lbl_ItemCount.text = String(itmQty)
    }
    @IBAction func AddBucketItem(_ sender: Any) {
        if let itemName = tf_itemName.text?.trimmingCharacters(in: [" "]) {
            if itemName.isEmpty{
                showToastAlert(message: "Name must not be empty")
                return
            }
            
            var itemUnit = tf_unit.text?.trimmingCharacters(in: [" "])
            if itemUnit == "other"{
                itemUnit = tf_unit_other.text?.trimmingCharacters(in: [" "])
            }
            var itemVariation = tf_variation.text?.trimmingCharacters(in: [" "])
            if itemVariation == "other"{
                itemVariation = tf_variation_other.text?.trimmingCharacters(in: [" "])
            }
           
            ProgressHUD.animate()
            if let isEditingItem = self.isEditingItem , isEditingItem{
                updateBucketItem(name: itemName, unit: itemUnit ?? "", itemVariation: itemVariation ?? "")
            } else {
                AddBucketItem(name : itemName , unit : itemUnit ?? "")
            }
        } else {
            showToastAlert(message: "Name must not be empty")
        }
    }
    func updateBucketItem(name: String , unit : String , itemVariation : String){
        AuthService.updateBucketItem(bucketID: String(self.bucketID ?? 0) , itemID: String(selecteditemData?.id ?? 0), name: name, price: "0" , variation: itemVariation, unit: unit , quantity: String(itmQty), description: tf_instructions.text ?? ""){ result in
            switch result {
            case .success( (_, _)):
                
                AppLogger.general.info("Update Item API Success:")
                ProgressHUD.dismiss()
                self.showToastAlert(message: "Item successfully updated") {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                AppLogger.error.error("Update Item API failed: \(error.localizedDescription)")
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
    func AddBucketItem(name : String, unit : String){
        AuthService.addBucketItem(bucketID: String(self.bucketID ?? 0), variation: tf_variation.text ?? "", name: name, price: "0", unit: unit, quantity: String(itmQty), description: tf_instructions.text ?? ""){ result in
            switch result {
            case .success(let (response, headers)):
                
                AppLogger.general.info("AddItem API Success:")
                ProgressHUD.dismiss()
                self.showToastAlert(message: "Item successfully added") {
                    self.navigationController?.popViewController(animated: true)
                }
               
                
            case .failure(let error):
                AppLogger.error.error("Add item API failed: \(error.localizedDescription)")
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
