//
//  ComparisonViewController.swift
//  Grocery Management
//
//  Created by mac on 20/06/2025.
//

import UIKit
import ProgressHUD

struct PairedListData {
    var itemA: ItemsBucket?
    var itemB: ItemsBucket?
    
    var priceDifference: Double? {
            guard let priceA = itemA?.price, let priceB = itemB?.price else { return nil }
            return priceB - priceA
        }
    
}

class ComparisonViewController: UIViewController , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var lblListA: UILabel!
    @IBOutlet weak var lblListB: UILabel!
    @IBOutlet weak var tableComparison: UITableView!
    
    var idListA : Int?
    var idListB : Int?
    
    var invoicesListData : [ListData]?
    
    var invoiceAdata : ListData? = nil
    var invoiceBdata : ListData? = nil
    
    var finalDisplayList : [PairedListData]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
       
        if let dataList = invoicesListData {
            invoiceAdata = dataList.first(where: { $0.id == idListA })
            invoiceBdata = dataList.first(where: { $0.id == idListB })
        }
        self.lblListA.text = invoiceAdata?.name
        self.lblListB.text = invoiceBdata?.name
        
        self.setupNavigationBackButton {
            self.navigationController?.popViewController(animated: true)
        }
        
        compareLists()
    }
    
    @IBAction func changeListB(_ sender: Any) {
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
               
                DispatchQueue.main.asyncAfter(deadline: .now()+1){
                    ProgressHUD.dismiss()
                    self.idListB = selectedListID
                    self.invoiceBdata = self.invoicesListData?.first(where: { $0.id == self.idListB })
                    self.lblListB.text = self.invoiceBdata?.name
                    self.compareLists()
                }
            }
            self.present(controller, animated: true)
        }
    }
    
    func compareLists(){
        finalDisplayList = pairListsByName(listA: invoiceAdata?.items ?? [], listB: invoiceBdata?.items ?? [])
        
        self.tableComparison.delegate = self
        self.tableComparison.dataSource = self
        
        self.tableComparison.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        finalDisplayList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompareInvoicesListTableViewCell") as! CompareInvoicesListTableViewCell
        if let pair = finalDisplayList?[indexPath.row]{
            cell.configure(with: pair)
        }
        return cell
    }
    
    

    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
       
    }
    
    func pairListsByName(listA: [ItemsBucket], listB: [ItemsBucket]) -> [PairedListData] {
        var result: [PairedListData] = []
        
        var usedBIndexes = Set<Int>()

        for itemA in listA {
            if let indexB = listB.firstIndex(where: { $0.name == itemA.name }) {
                result.append(PairedListData(itemA: itemA, itemB: listB[indexB]))
                usedBIndexes.insert(indexB)
            } else {
                result.append(PairedListData(itemA: itemA, itemB: nil))
            }
        }

        
        for (index, itemB) in listB.enumerated() where !usedBIndexes.contains(index) {
            result.append(PairedListData(itemA: nil, itemB: itemB))
        }

        return result
    }
    
}
