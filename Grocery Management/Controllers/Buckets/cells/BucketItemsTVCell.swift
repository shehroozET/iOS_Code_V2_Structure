//
//  BucketItemsTVCell.swift
//  Grocery Management
//
//  Created by mac on 04/06/2025.
//

import UIKit

class BucketItemsTVCell: UITableViewCell {
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var item_variations: UILabel!
    @IBOutlet weak var item_qty: UILabel!
    @IBOutlet weak var item_notes: UILabel!
    @IBOutlet weak var item_unit: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
