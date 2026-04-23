//
//  colorCollectionViewCell.swift
//  Grocery Management
//
//  Created by mac on 14/05/2025.
//

import UIKit

class colorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var color_view: UIView!

    @IBOutlet weak var color: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        makeColorViewRound()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        makeColorViewRound()
    }

    private func makeColorViewRound() {
        color_view.layer.cornerRadius = color_view.frame.size.width / 2
        color.layer.cornerRadius = color.frame.size.width / 2
        color_view.clipsToBounds = true
        color.clipsToBounds = true
    }
    
    func updateBorder(isSelected: Bool) {
        if isSelected {
            color_view.layer.borderWidth = 2
            color_view.layer.borderColor = UIColor.black.cgColor
        } else {
            color_view.layer.borderWidth = 0
            color_view.layer.borderColor = nil
        }
    }
}
