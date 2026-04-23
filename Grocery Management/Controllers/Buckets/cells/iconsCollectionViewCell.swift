//
//  iconsCollectionViewCell.swift
//  Grocery Management
//
//  Created by mac on 14/05/2025.
//

import UIKit

class iconsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var icon_image: UIImageView!
    @IBOutlet weak var icon_view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeViewRound()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        makeViewRound()
    }

    private func makeViewRound() {
        icon_image.layer.cornerRadius = icon_image.frame.size.width / 2
        icon_image.clipsToBounds = true
    }
    
    func updateBorder(isSelected: Bool) {
        if isSelected {
            icon_view.layer.cornerRadius = icon_view.frame.size.width / 2
            icon_view.layer.borderWidth = 2
            icon_view.layer.borderColor = UIColor.black.cgColor
        } else {
            icon_view.layer.cornerRadius = 0
            icon_view.layer.borderWidth = 0
            icon_view.layer.borderColor = nil
        }
    }
    
}
