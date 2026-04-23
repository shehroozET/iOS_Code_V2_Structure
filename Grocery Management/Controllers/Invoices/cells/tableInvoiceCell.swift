//
//  tableInvoiceCell.swift
//  Grocery Management
//
//  Created by mac on 18/06/2025.
//

import UIKit

class tableInvoiceCell: UITableViewCell {
    @IBOutlet weak var dateCreated: UILabel!
    @IBOutlet weak var viewBgCell: UIView!
    @IBOutlet weak var bucketName: UILabel!
    @IBOutlet weak var totalItems: UILabel!
    @IBOutlet weak var imageViewBucket: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
