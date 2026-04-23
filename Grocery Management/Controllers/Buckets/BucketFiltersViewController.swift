//
//  BucketFiltersViewController.swift
//  Grocery Management
//
//  Created by mac on 01/05/2025.
//

import UIKit

class BucketFiltersViewController: UIViewController {
    
    private let datePicker = UIDatePicker()
    private var activeTextField: UITextField?
    
    @IBOutlet weak var capsuleShared: UIButton!
    @IBOutlet weak var capsuleMine: UIButton!
    @IBOutlet weak var capsuleAll: UIButton!
    
    var onApplyFilters: ((_ startDate: String?, _ endDate: String? , _ filterType : String?) -> Void)?
    var startDate = ""
    var endDate = ""
    var isFromInvoice : Bool? = false
    var filterType = "all"
    @IBOutlet var tf_sdate : UITextField!
    @IBOutlet var tf_edate : UITextField!
    

   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Filter"
        setupDatePickers()
        tf_sdate.text = startDate
        tf_edate.text = endDate
        print("startDate = " , startDate )
        print("tf_sdate = " , tf_sdate.text)
        print("endDate = " , endDate)
        print( "tf_edate" , tf_edate.text)
        
        self.capsuleAll.layer.cornerRadius = 5
        self.capsuleMine.layer.cornerRadius = 5
        self.capsuleShared.layer.cornerRadius = 5
        
        switch self.filterType{
        case "all":
            self.selecteCapsule(buttons: [capsuleAll , capsuleMine , capsuleShared], selectedButton: capsuleAll)
        case "own":
            self.selecteCapsule(buttons: [capsuleAll , capsuleMine , capsuleShared], selectedButton: capsuleMine)
        case "shared":
            self.selecteCapsule(buttons: [capsuleAll , capsuleMine , capsuleShared], selectedButton: capsuleShared)
        default:
            self.selecteCapsule(buttons: [capsuleAll , capsuleMine , capsuleShared], selectedButton: capsuleAll)
        }
        
        if let isFromInvoice = self.isFromInvoice , isFromInvoice{
            capsuleAll.isEnabled = false
            capsuleMine.isEnabled = false
            capsuleShared.isEnabled = false
        }
    }
    func selecteCapsule(buttons : [UIButton] , selectedButton : UIButton?){
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
    @IBAction func allFilter(_ sender: Any) {
        filterType = "all"
        self.selecteCapsule(buttons: [capsuleAll , capsuleMine , capsuleShared], selectedButton: capsuleAll)
    }
    
    @IBAction func mineFilter(_ sender: Any) {
        filterType = "own"
        self.selecteCapsule(buttons: [capsuleAll , capsuleMine , capsuleShared], selectedButton: capsuleMine)
    }
    
    @IBAction func sharedFilter(_ sender: Any) {
        filterType = "shared"
        self.selecteCapsule(buttons: [capsuleAll , capsuleMine , capsuleShared], selectedButton: capsuleShared)
    }
    
    func setupDatePickers() {
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels

            if #available(iOS 13.4, *) {
                datePicker.locale = Locale(identifier: "en_GB")
            }

            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
            toolbar.setItems([doneButton], animated: true)

        [tf_sdate, tf_edate].forEach { textField in
                textField?.inputView = datePicker
                textField?.inputAccessoryView = toolbar
                textField?.delegate = self
            }
        }

        @objc func donePressed() {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            let dateString = formatter.string(from: datePicker.date)

            activeTextField?.text = dateString
            activeTextField?.resignFirstResponder()
        }
    
    @IBAction func applyFilters(_ sender: Any) {
        startDate = tf_sdate.text!
        endDate = tf_edate.text!
        applyButtonTapped()
    }
    func applyButtonTapped() {
          let selectedStartDate = tf_sdate.text
        let selectedEndDate = tf_edate.text
        print("selected startDate = \(selectedStartDate)")
        print("selected EndDate = \(selectedEndDate)")
        onApplyFilters?(selectedStartDate, selectedEndDate , filterType)
          self.dismiss(animated: true)
      }
    @IBAction func resetDates(_ sender: Any) {
        tf_edate.text = ""
        tf_sdate.text = ""
        startDate = ""
        endDate = ""
        filterType = "all"
        self.selecteCapsule(buttons: [capsuleAll , capsuleMine , capsuleShared], selectedButton: capsuleAll)
    }
    
}
extension BucketFiltersViewController: UITextFieldDelegate {
   func textFieldDidBeginEditing(_ textField: UITextField) {
       activeTextField = textField
   }
}
