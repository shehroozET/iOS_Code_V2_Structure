//
//  GlobalSearchTableViewCell.swift
//  Grocery Management
//
//  Created by mac on 17/06/2025.
//

import UIKit

class GlobalSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var iv_item: UIImageView!
    @IBOutlet weak var itemType: UILabel!
    @IBOutlet weak var totalItems: UILabel!
    @IBOutlet weak var dateCreated: UILabel!
    @IBOutlet weak var viewCell: UIView!
    @IBOutlet weak var title: UILabel!
//    @IBOutlet weak var type: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
