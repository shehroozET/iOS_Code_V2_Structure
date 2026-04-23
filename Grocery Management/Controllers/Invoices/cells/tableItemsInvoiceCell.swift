//
//  tableItemsInvoiceCell.swift
//  Grocery Management
//
//  Created by mac on 18/06/2025.
//

import UIKit

class tableItemsInvoiceCell: UITableViewCell {

    @IBOutlet weak var dateCreated: UILabel!
    @IBOutlet weak var listItems: UILabel!
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
