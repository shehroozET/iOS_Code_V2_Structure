//
//  FindFriendsTableViewCell.swift
//  Grocery Management
//
//  Created by mac on 26/06/2025.
//

import UIKit

protocol BucketShareTVCellDelegate: AnyObject {
    func didTapShare(userID: String , name : String)
}

protocol BucketDeleteTVCellDelegate: AnyObject {
    func didTapDelete(userID: String , name : String)
}

class FindFriendsTableViewCell: UITableViewCell {
    @IBOutlet weak var iv_image: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    weak var shareDelegate: BucketShareTVCellDelegate?
    weak var deleteDelegate: BucketDeleteTVCellDelegate?
    var userID : String? // also act as bucketID when user already has access
    var name : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
            guard let id = userID else { return }
        shareDelegate?.didTapShare(userID: id , name: self.name ?? "")
        deleteDelegate?.didTapDelete(userID: id , name: self.name ?? "")
        }

}
