//
//  ShareBucketViewController.swift
//  Grocery Management
//
//  Created by mac on 26/06/2025.
//

import UIKit
import ProgressHUD
import AlamofireImage

class ShareBucketViewController: UIViewController , UITextFieldDelegate , BucketShareTVCellDelegate , BucketDeleteTVCellDelegate{
    func didTapDelete(userID: String, name: String) {
        AuthService.deleteSharedBucket(bucketID: userID){
            result in
            switch result
            {
            case .success(_):
                AppLogger.debug.info("Delete API successfull: shared with ID = \(userID) name =  \(name)")
                self.showToastAlert(message: "List Shared Permission removed for \(name)")
                BucketListManager.shared.getLatestData()
           
                
            case .failure(let error):
                self.showToastAlert(message: error.localizedDescription)
                AppLogger.debug.info("Delete API Failed:\(error.localizedDescription)")
            }
        }
    }
    
    func didTapShare(userID: String , name : String) {
        AuthService.shareBucket(bucketID: String(bucketID ?? 0), userIDToShareBucket: userID){
            result in
            switch result
            {
            case .success(_):
                AppLogger.debug.info("Share API successfull: shared with ID = \(userID) name =  \(name)")
                self.showToastAlert(message: "List Shared with \(name)")
                BucketListManager.shared.getLatestData()
          
            case .failure(let error):
                self.showToastAlert(message: error.localizedDescription)
                AppLogger.debug.info("Share API Failed:\(error.localizedDescription)")
            }
        }
    }
    

    @IBOutlet weak var noItemsView: UILabel!
    @IBOutlet weak var lblSearchUsers: UILabel!
    @IBOutlet weak var tf_search: UITextField!
    @IBOutlet weak var tableFriends: UITableView!
    var bucketID : Int? = nil
    var sharedListData : [SharedList]?
    var isSearching = false
    var isSharedUsersExists = false
    var searchDebounceTimer : Timer?
    
    var data : [UsersFound] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Share Bucket"
        self.setupNavigationBackButton(){
            self.navigationController?.popViewController(animated: true)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .apiFetchedData, object: nil)
        
        self.tf_search.delegate = self
        self.tf_search.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.isSharedUsersExists = sharedListData?.count ?? 0 > 0
        setAlreadySharedUserList()
        
    }
    @objc func reloadData(){
       
        self.sharedListData  = BucketListManager.shared.sharedListData
        self.tableFriends.reloadData {
            ProgressHUD.dismiss()
            self.setAlreadySharedUserList()
        }
        
    }
    override func viewDidDisappear(_ animated : Bool){
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .apiFetchedData, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .apiFetchedData, object: nil)
    }
    func setAlreadySharedUserList(){
        if isSharedUsersExists{
            self.lblSearchUsers.isHidden = true
            self.noItemsView.isHidden = true
            self.tableFriends.isHidden = false
            
        } else {
            self.lblSearchUsers.isHidden = false
        }
        tableFriends.reloadData()
        tableFriends.delegate = self
        tableFriends.dataSource = self
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
       
        searchDebounceTimer?.invalidate()
        
        let query = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if query.isEmpty {
            isSearching = false
            noItemsView.isHidden = true
            data = []
            setAlreadySharedUserList()
        } else {
            isSearching = true
            searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                ProgressHUD.animate()
                self.searchUser(text : query)
                
            }
        }
    }
    func searchUser(text : String){
        AuthService.searchUser(email: text){
            result in
            switch result {
            case .success(let (response, _)):
                AppLogger.general.info("API search Successfull: user Search API")
                
                self.tableFriends.isHidden = false
                self.data = response.data ?? []
                
                self.tableFriends.delegate = self
                self.tableFriends.dataSource  = self
                if let data = response.data , data.count > 0{
                    self.noItemsView.isHidden = true
                    self.tableFriends.isHidden = false
                } else {
                    self.noItemsView.isHidden = false
                    self.lblSearchUsers.isHidden = true
                    self.tableFriends.isHidden = true
                }
                
                self.tableFriends.reloadData {
                    ProgressHUD.dismiss()
                }
            case .failure(let error):
                AppLogger.error.error("User Search API failed: \(error.localizedDescription)")
                switch error {
                case .backendError(let data):
                    do {
                        let decoded = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                        if let messages = decoded.errors {
                            ProgressHUD.failed(messages.joined(separator: "\n"))
                        } else {
                            ProgressHUD.failed("Something went wrong.")
                        }
                    } catch {
                        ProgressHUD.failed("Data corrupted")
                    }
                    
                default:
                    ProgressHUD.failed(error.localizedDescription)
                }
            }
        }
    }
}
extension ShareBucketViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSharedUsersExists && !isSearching{
            return sharedListData?.count ?? 0
        }
        return self.data.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(sharedListData?.count ?? 0 > 0 || isSearching){
            let headerView = UIView()
            headerView.backgroundColor = UIColor.init(named: "headerBG")
            headerView.layer.cornerRadius = 10
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = (isSharedUsersExists && !isSearching) ? "Shared With" : "Share with"
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textColor = .darkGray
            
            headerView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
                label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
            ])
            
            return headerView
        }
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(sharedListData?.count ?? 0 > 0 || isSearching){
            return 40
        }
        return 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (isSharedUsersExists && !isSearching) ? "Shared With" : "Share with"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindFriendsTableViewCell", for: indexPath) as! FindFriendsTableViewCell
       
        if isSharedUsersExists, let sharedUser = sharedListData?[safe: indexPath.row] , !isSearching {
            cell.lblName.text = sharedUser.sharedTo?.userName ?? ""
            
           
                cell.iv_image.image = createInitialImage(name: sharedUser.sharedTo?.userName ?? "G")
            cell.shareButton.isHidden = false
            cell.deleteDelegate = self
            cell.userID = String(sharedUser.id ?? 0)
            self.lblSearchUsers.isHidden = true
            cell.name = sharedUser.sharedTo?.userName ?? ""
            setButton(cell: cell , canRemove: true)
           
            
        } else {
            let data = data[indexPath.row]
            
            cell.lblName.text = data.userName ?? ""
            
            self.lblSearchUsers.isHidden = true
            if let urlString = data.pictureURL, let url = URL(string: urlString) {
                cell.iv_image.af.setImage(withURL: url)
            } else {
                cell.iv_image.image = createInitialImage(name: data.userName ?? "G")
            }
            cell.userID = String(data.id ?? 0)
            cell.name = data.userName ?? ""
            cell.shareDelegate = self
           
            let isShared = self.sharedListData?.contains(where: { $0.sharedTo?.id == data.id }) ?? false
            if isShared{
                cell.shareButton.isHidden = true
            }
            setButton(cell: cell, canRemove: false)
            
        }
        return cell
        
    }
    
    func setButton(cell : FindFriendsTableViewCell , canRemove : Bool){
        if canRemove{
           
            cell.shareButton.setTitle("remove", for: .normal)
            cell.shareButton.tintColor = .red
            cell.shareButton.titleLabel?.textColor = .red
            cell.shareButton.titleLabel?.font = UIFont(name: "DMSans-Regular", size: 12)
            
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            let image = UIImage(systemName: "trash", withConfiguration: config)
            cell.shareButton.setImage(image, for: .normal)
        } else {
           
            cell.shareButton.setTitle("share", for: .normal)
            cell.shareButton.tintColor = UIColor(named: "CapsuleBG")
            cell.shareButton.titleLabel?.textColor = .green
            cell.shareButton.titleLabel?.font = UIFont(name: "DMSans-Regular", size: 12)
            
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
            let image = UIImage(systemName: "square.and.arrow.up", withConfiguration: config)
            cell.shareButton.setImage(image, for: .normal)
        }
    }
    func tableView(_ tableView : UITableView, didSelectRowAt indexPath : IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
