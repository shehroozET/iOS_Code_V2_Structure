//
//  ProfileViewController.swift
//  Grocery Management
//
//  Created by mac on 05/05/2025.
//

import UIKit
import ProgressHUD
import Photos
import ImageIO
import MobileCoreServices
import Alamofire

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var tf_location: UITextField!
    @IBOutlet weak var tf_gender: UITextField!
    @IBOutlet weak var tf_phone: UITextField!
    
    @IBOutlet weak var tf_email: UITextField!
    
    @IBOutlet weak var tf_username: UITextField!
    @IBOutlet weak var iv_profile: UIImageView!
    
    var profileData : UserProfile?
    
    var currency = ""
    var location = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Edit Profile"
        self.setupNavigationBackButton(){
            self.navigationController?.dismiss(animated: true)
        }
        self.setupUI()
        self.loadProfileData(){
            self.setupUI()
        }
        
    }
    func loadProfileData(completion: @escaping () -> Void) {
        AuthService.getUserProfile{ result in
            switch result {
            case .success(let (response, _)):
                ProgressHUD.dismiss()
                AppLogger.general.info("Profile API Successfully gets data:")
                let data = response
                self.profileData = data
                completion()
            case .failure(let error):
                ProgressHUD.dismiss()
                AppLogger.error.error("\(error.localizedDescription)")
                self.showToastAlert(message: "Error getting Profile"){
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self , action: #selector(selectLocation))
        tf_location.addGestureRecognizer(tapGesture)
    }
    @objc func selectLocation(){
        let board = UIStoryboard(name: "Settings", bundle: nil)
        if let controller = board.instantiateViewController(withIdentifier: "CountryViewController") as? CountryViewController{
            controller.modalPresentationStyle = .pageSheet
            controller.title = "select country"
            controller.onCountrySelected = { country, currency in
                self.currency = currency
                self.location = country
                self.tf_location.text = country + " - " + currency
            }
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    func setupUI(){
        if let profileData = self.profileData{
            self.tf_email.text = profileData.email
            if let phone = profileData.phone{
                self.tf_phone.text = String(phone)
            } else {
                self.tf_phone.text = ""
            }
            self.tf_gender.text = profileData.gender
            self.tf_location.text = profileData.location
            self.tf_username.text = profileData.userName
            
        } else {
            self.tf_email.text = UserSettings.shared.email
            
            self.tf_phone.text = String(UserSettings.shared.phone)
            
            self.tf_gender.text = UserSettings.shared.gender
            self.tf_location.text = UserSettings.shared.location
            self.tf_username.text = UserSettings.shared.userName
        }
        if let urlString = UserSettings.shared.userImage, let url = URL(string: urlString) {
            iv_profile.af.setImage(withURL: url)
        } else {
            iv_profile.image = createInitialImage(name: UserSettings.shared.userName)
        }
        iv_profile.layer.cornerRadius = iv_profile.frame.height/2
        iv_profile.layer.borderWidth = 1
        iv_profile.layer.borderColor = UIColor.black.cgColor
    }
    @IBAction func editProfileImage(_ sender: Any) {
        setupProfilePic()
    }
    func setupProfilePic(){
        let alert = UIAlertController(title: "Choose Source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default) { _ in self.openCamera() })
        alert.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in self.openGallery() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    
    
    func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    func openGallery() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    // MARK: - Image Picker Delegate
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        ProgressHUD.animate()
        if let image = info[.originalImage] as? UIImage {
            iv_profile.image = image

            // Save camera image to library (if needed)
            if info[.referenceURL] == nil {
                // Camera image - save it
                var localIdentifier: String?

                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
                }) { success, error in
                    DispatchQueue.main.async {
                        if success, let id = localIdentifier {
                            let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
                            if let asset = assetResult.firstObject {
                                self.getMetadataFromAsset(asset: asset) { metadata in
                                    if let meta = metadata {
                                        print("✅ Metadata:", meta)
                                        print("📅 Date Taken:", meta["creationDate"] ?? "N/A")
                                        print("📍 Location:", meta["latitude"] ?? "-", ",", meta["longitude"] ?? "-")
                                    } else {
                                        print("❌ No metadata found.")
                                    }
                                }
                            }
                        } else {
                            print("❌ Failed to save image to library: \(error?.localizedDescription ?? "unknown error")")
                        }
                    }
                }
            } else {
                // Photo from gallery – already has referenceURL - need to update the reference as these are deprecated in iOS 11 - Old code
                if let assetURL = info[.referenceURL] as? URL {
                    let result = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil)
                    if let asset = result.firstObject {
                        getMetadataFromAsset(asset: asset) { metadata in
                            if let meta = metadata {
                                print("✅ Metadata:", meta)
                                print("📅 Date Taken:", meta["creationDate"] ?? "N/A")
                                print("📍 Location:", meta["latitude"] ?? "-", ",", meta["longitude"] ?? "-")
                            } else {
                                print("❌ No metadata found.")
                            }
                        }
                    }
                }
            }

            let baseURL = Config.shared.configuration.api
            //uploadImage(image: image, to: baseURL+"/api/v1/user/profiles")
        }
        picker.dismiss(animated: true)
    }
    func getMetadataFromAsset(asset: PHAsset, completion: @escaping ([String: Any]?) -> Void) {
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true

        asset.requestContentEditingInput(with: options) { input, _ in
            guard let url = input?.fullSizeImageURL else {
                print("Could not get image URL from PHAsset.")
                completion(nil)
                return
            }

            guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil) else {
                print("Failed to create image source.")
                completion(nil)
                return
            }

            var metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] ?? [:]

            // Inject creationDate from PHAsset
            if let creationDate = asset.creationDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                metadata["creationDate"] = formatter.string(from: creationDate)
            }

            // Also inject location if needed
            if let location = asset.location {
                metadata["latitude"] = location.coordinate.latitude
                metadata["longitude"] = location.coordinate.longitude
            }

            completion(metadata)
        }
    }


    func extractMetadata(from image: UIImage) -> [String: Any]? {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }

        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, sourceOptions) else { return nil }

        if let metadata = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any] {
            return metadata
        }
        return nil
    }

    @IBAction func saveSettings(_ sender: Any) {
        ProgressHUD.animate()
        AuthService.updateProfile(username: tf_username.text ?? "" , email: tf_email.text ?? ""  , phone: tf_phone.text ?? "" , gender: tf_gender.text ?? "" , location: self.location , currency : self.currency ){ result in
            switch result {
            case .success(let (response, _)):
                ProgressHUD.dismiss()
                if let data = response.data
                {
                    UserSettings.shared.update(settings: [
                        "sound": data.setting?.sound ?? false,
                        "vibrate": data.setting?.vibrate ?? false,
                        "push_notification": data.setting?.pushNotification ?? false,
                        "email_notification": data.setting?.emailNotification ?? false,
                        "user_name": data.userName ?? "Groceipt user",
                        "user_image": data.profileImage ?? "",
                        "email": data.email ?? "",
                        "phone": data.phone ?? "",
                        "gender": data.gender ?? "",
                        "location" : data.location ?? "",
                        "currency": data.currency ?? "$",
                        "id": data.id ?? 0
                    ])
                }
                
                AppLogger.general.info("Profile API Successfully gets data:")
                self.showToastAlert(message: "Profile updated"){
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                ProgressHUD.dismiss()
                AppLogger.error.error("\(error.localizedDescription)")
                self.showToastAlert(message: "Error getting Profile"){
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    func uploadImage(image: UIImage, to urlString: String, fileName: String = "image.jpg", paramName: String = "user[picture]") {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            self.showToastAlert(message: "Failed to convert image")
            return
        }
        
        var headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            
        ]
        if let token = TokenManager.shared.token {
            headers.add(name: "Access-Token", value: token)
        }
        if let client = TokenManager.shared.client {
            headers.add(name: "Client", value: client)
        }
        if let uid = TokenManager.shared.uid {
            headers.add(name: "Uid", value: uid)
        }
       
       
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: paramName, fileName: fileName, mimeType: "image/jpeg")
            
        }, to: urlString, method: .put, headers: headers)
        .validate()
        .responseDecodable(of: UploadImage.self) { response in
            switch response.result {
            case .success(let data):
                if let url = data.data?.pictureURL{
                    UserSettings.shared.userImage = url
                }
                
                ProgressHUD.dismiss()
                self.showToastAlert(message: "Profile picture updated")
                
            case .failure(let error):
                self.showToastAlert(message: "Upload failed: \(error.localizedDescription)")
               
            }
        }
    }
}
