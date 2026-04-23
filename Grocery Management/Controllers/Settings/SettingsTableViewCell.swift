//
//  SettingsTableViewCell.swift
//  Grocery Management
//
//  Created by mac on 13/05/2025.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var name_settings: UILabel!
    @IBOutlet weak var icon_settings: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
