//
//  compareInvoicesListTableViewCell.swift
//  Grocery Management
//
//  Created by mac on 20/06/2025.
//

import UIKit

class CompareInvoicesListTableViewCell: UITableViewCell {
    @IBOutlet weak var itemNameA: UILabel!
    @IBOutlet weak var itemNameB: UILabel!
    
    @IBOutlet weak var itemPriceA: UILabel!
    @IBOutlet weak var itemPriceB: UILabel!
    
    @IBOutlet weak var lblPriceDifferences: UILabel!
    @IBOutlet weak var lblCurrency: UILabel!
    
    @IBOutlet weak var itemQTYA: UILabel!
    @IBOutlet weak var itemQTYB: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(with pair: PairedListData ) {
        if let a = pair.itemA {
            itemNameA.text = a.name ?? ""
            itemPriceA.text = UserSettings.shared.currency + String(a.price ?? 0)
            itemQTYA.text = String(a.quantity ?? 0)
        } else {
            itemNameA.text = "-"
            itemPriceA.text = "-"
            itemQTYA.text = "-"
        }
        
        if let b = pair.itemB {
            itemNameB.text = b.name ?? ""
            itemPriceB.text = UserSettings.shared.currency + String(b.price ?? 0)
            itemQTYB.text = String(b.quantity ?? 0)
        } else {
            itemNameB.text = "-"
            itemPriceB.text = "-"
            itemQTYB.text = "-"
        }
        
        if let priceA = pair.itemA?.price, let priceB = pair.itemB?.price {
            let difference = priceB - priceA
            let percentChange = (difference / priceA) * 100
            let formattedDiff = String(format: "%.2f", abs(difference))
            let formattedPercent = String(format: "%.0f", abs(percentChange))
            
            let arrow = difference >= 0 ? "▲" : "▼"
            let color = difference >= 0 ? UIColor.systemGreen : UIColor.systemRed
            lblPriceDifferences.text = (difference >= 0
                                        ? "+\(formattedDiff) (\(formattedPercent)%) \(arrow)"
                                        : "-\(formattedDiff) (\(formattedPercent)%) \(arrow)")
            
            lblPriceDifferences.textColor = difference >= 0 ? .systemGreen : .systemRed
            lblCurrency.text = "Diff: \(UserSettings.shared.currency)"
            
        } else {
            lblPriceDifferences.text = "--"
            lblPriceDifferences.textColor = .gray
        }
        
    }
    func showDifference(oldValue: Double, newValue: Double, label: UILabel) {
        let difference = newValue - oldValue

        let formatted = String(format: "%.2f", abs(difference))
        label.text = (difference >= 0 ? "+\(formatted)" : "-\(formatted)")

        label.textColor = difference >= 0 ? .systemGreen : .systemRed
    }
    

}
