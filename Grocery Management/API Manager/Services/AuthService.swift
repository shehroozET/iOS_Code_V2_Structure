//
//  AuthService.swift
//  Grocery Management
//
//  Created by mac on 19/05/2025.
//
import Alamofire

struct AuthService {
    static func login(
        email: String,
        password: String,
        completion: @escaping (Result<(LoginResponse, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.login(email: email, password: password),
            responseType: LoginResponse.self,
            completion: completion
        )
    }
    
    static func googleSignIn(
        email: String,
        name: String,
        completion: @escaping (Result<(LoginResponse, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.googleSignIn(email: email, name: name),
            responseType: LoginResponse.self,
            completion: completion
        )
    }
    
    static func register(
        user_name : String,
        email: String,
        password: String,
        password_confirmation: String,
        completion: @escaping (Result<(RegistrationResponse, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.register(user_name: user_name, email: email, password: password, password_confirmation: password_confirmation),
            responseType: RegistrationResponse.self,
            completion: completion
        )
    }
    
    static func sendCode(
        email: String,
        completion: @escaping (Result<(SendCode, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.sendCode(email: email),
            responseType: SendCode.self,
            completion: completion
        )
    }
    
    static func verifyCode(
        email: String,
        code: String,
        completion: @escaping (Result<(VerifyCode, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.verifyCode(email: email, code: code),
            responseType: VerifyCode.self,
            completion: completion
        )
    }
    
    static func updatePassword(
        email: String,
        code: String,
        password : String ,
        password_confirmation : String,
        completion: @escaping (Result<(UpdatePassword, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.updatePassword(email: email, code: code, password: password, password_confirmation: password_confirmation),
            responseType: UpdatePassword.self,
            completion: completion
        )
    }
    
    static func getBucketList(
        completion: @escaping (Result<(BucketList, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.getBucketList,
            responseType: BucketList.self,
            completion: completion
        )
    }
    
    static func createBucketList(
        userID: String,
        name: String,
        color : String,
        icon : String,
        items : [BucketItem],
        completion: @escaping (Result<(CreateBucket, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.createBucketList(userID: userID, bucketName: name, color: color, icon: icon , items: items),
            responseType: CreateBucket.self,
            completion: completion
        )
    }
    
    static func deleteBucket(
        bucketID : String,
        completion: @escaping (Result<(DeleteBucket,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.deleteBucket(bucketID: bucketID),
            responseType: DeleteBucket.self,
            completion: completion
        )
    }
    static func deleteSelectedItem(
        listID : String,
        items : [DeletedItems],
        completion: @escaping (Result<(DeleteBucket,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.deleteSelectedItems(listID: listID, items: items),
            responseType: DeleteBucket.self,
            completion: completion
        )
    }
     static func deleteSelectedBucketItems(
        listID : String,
        items : [DeletedItems],
        completion: @escaping (Result<(DeleteBucket,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.deleteSelectedBucketItems(bucketID: listID, items: items),
            responseType: DeleteBucket.self,
            completion: completion
        )
    }
    
    static func markAsPurchased(
        itemId : String,
        is_purchased : Bool,
        completion: @escaping (Result<(DeleteBucket,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.markAsPurchased(itemId: itemId, is_purchased: is_purchased),
            responseType: DeleteBucket.self,
            completion: completion
        )
    }
    
    static func searchUser(
        email : String,
        completion: @escaping (Result<(FindUsers,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.searchUser(email: email),
            responseType: FindUsers.self,
            completion: completion
        )
    }
    
    static func shareBucket(
        bucketID : String,
        userIDToShareBucket : String,
        completion: @escaping (Result<(DeleteBucket,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.shareBucket(userIDToShareBucket: userIDToShareBucket, bucketID: bucketID),
            responseType: DeleteBucket.self,
            completion: completion
        )
    }
    
     static func deleteSharedBucket(
        bucketID : String,
        completion: @escaping (Result<(DeleteBucket,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.deleteSharedBucket(bucketID: bucketID),
            responseType: DeleteBucket.self,
            completion: completion
        )
    }
    
    
    static func updateBucket(
        bucketID : String,
        userID: String,
        name: String,
        color : String,
        icon : String,
        completion: @escaping (Result<(UpdateBucket,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.updateBucket(bucketID: bucketID, userID: userID, bucketName: name, color: color, icon: icon),
            responseType: UpdateBucket.self,
            completion: completion
        )
    }
    
    static func getBucketItems(
        bucketID : String,
        type: String,
        completion: @escaping (Result<(BucketItemsData,[AnyHashable : Any]), APIError>) -> Void
    ){
        APIClient.shared.request(
            APIRouter.getBucketItems(bucketID: bucketID, itemable_type: type),
            responseType: BucketItemsData.self,
            completion: completion
        )
    }
    
    static func addBucketItem(
        bucketID : String,
        variation: String,
        name: String,
        price : String,
        unit : String,
        quantity : String,
        description : String,
        completion: @escaping (Result<(UpdateBucket,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.addBucketItems(bucketID: bucketID, variation: variation, name: name, price: price, unit: unit, quantity: quantity, description: description),
            responseType: UpdateBucket.self,
            completion: completion
        )
    }
    
    static func updateBucketItem(
        bucketID : String,
        itemID : String,
        name: String,
        price : String,
        variation : String,
        unit : String,
        quantity : String,
        description : String,
        completion : @escaping (Result<(UpdateBucket,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.updateBucketItem(bucketID : bucketID , itemID: itemID, name: name, price: price, variation: variation, unit: unit, quantity: quantity, description: description),
            responseType: UpdateBucket.self,
            completion: completion)
    }
    
    static func deleteBucketItem(
        itemID : String ,
        bucketID : String ,
        completion : @escaping (Result<(UpdateBucket , [AnyHashable : Any]) , APIError>) -> Void
    )
    {
        APIClient.shared.request(
            APIRouter.deleteBucketItem(itemID: itemID , bucketlistID: bucketID),
            responseType: UpdateBucket.self,
            completion: completion)
    }
    
    static func searchBucket(
        filterType : String ,
        searchName : String ,
        startDate : String ,
        endDate : String ,
        bucket_type : String,
        completion : @escaping (Result<(BucketList , [AnyHashable : Any]) , APIError>) -> Void
    ) {
        APIClient.shared.request(APIRouter.searchBucketList(filterType: filterType, searchString: searchName, startDate: startDate, endDate: endDate , bucket_type : bucket_type), responseType: BucketList.self, completion: completion)
    }
    
    static func globalSearch(
        filterType : String ,
        searchName : String ,
        completion : @escaping (Result<(GlobalSearch , [AnyHashable : Any]) , APIError>) -> Void
    ) {
        APIClient.shared.request(APIRouter.globalSearch(filterKey: searchName, filterType: filterType), responseType: GlobalSearch.self, completion: completion)
    }
    
    static func getUserProfile(
        completion: @escaping (Result<(UserProfile, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.getUserProfile,
            responseType: UserProfile.self,
            completion: completion
        )
    }
    
    static func updateProfile(
        username: String, email: String, phone: String, gender: String, location: String, currency : String,
        completion: @escaping (Result<(LoginResponse, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.updateProfile(username: username, email: email, phone: phone, gender: gender, location: location , currency: currency),
            responseType: LoginResponse.self,
            completion: completion
        )
    }
    
    static func updateSettings(
        switch_sound : Bool,
        switch_vibrate : Bool,
        switch_push_notification : Bool,
        switch_email_notification : Bool,
        completion: @escaping (Result<(NotificationSettings, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.updateSettings(switch_sound: switch_sound, switch_vibrate: switch_vibrate, switch_push_notification: switch_push_notification, switch_email_notification: switch_email_notification),
            responseType: NotificationSettings.self,
            completion: completion
        )
    }
    
    static func changePassword(
        currentPassword : String,
        newPassword : String,
        confirmPassword : String,
        completion: @escaping (Result<(ChangePassword, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.changePassword(currentPassword: currentPassword, NewPassword: newPassword, confirmPassword: confirmPassword),
            responseType: ChangePassword.self,
            completion: completion
        )
    }
    
    static func searchInvoice(
        filterType : String ,
        searchName : String ,
        startDate : String ,
        endDate : String ,
        completion : @escaping (Result<(BucketList , [AnyHashable : Any]) , APIError>) -> Void
    ) {
        APIClient.shared.request(APIRouter.searchInvoiceList(filterType: filterType, searchString: searchName, startDate: startDate, endDate: endDate), responseType: BucketList.self, completion: completion)
    }
    
    static func getInvoiceList(
        completion: @escaping (Result<(BucketList, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.getInvoiceList,
            responseType: BucketList.self,
            completion: completion
        )
    }
    
    static func deleteInvoice(
        invoiceID : String,
        completion: @escaping (Result<(DeleteBucket,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.deleteInvoice(invoiceID: invoiceID),
            responseType: DeleteBucket.self,
            completion: completion
        )
    }
    
    static func createInvoiceList(
        userID: String,
        name: String,
        color : String,
        icon : String,
        items : [ScannedItem],
        completion: @escaping (Result<(CreateBucket, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.createInvoiceList(userID: userID, invoiceName: name, color: color, icon: icon , item: items),
            responseType: CreateBucket.self,
            completion: completion
        )
    }
    
    static func createAIInvoiceList(
        invoiceID : String,
        userID: String,
        name: String,
        color : String,
        icon : String,
        items : [ScannedItem],
        completion: @escaping (Result<(CreateBucket, [AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.createAIInvoiceItems(invoiceID: invoiceID, userID: userID, invoiceName: name, color: color, icon: icon, item: items),
            responseType: CreateBucket.self,
            completion: completion
        )
    }
    
    static func updateInvoice(
        invoiceID : String,
        userID: String,
        name: String,
        color : String,
        icon : String,
        completion: @escaping (Result<(UpdateBucket,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.updateInvoice(invoiceID: invoiceID, userID: userID, invoiceName: name, color: color, icon: icon),
            responseType: UpdateBucket.self,
            completion: completion
        )
    }
    
    static func getInvoiceItems(
        bucketID : String,
        type: String,
        completion: @escaping (Result<(BucketItemsData,[AnyHashable : Any]), APIError>) -> Void
    ){
        APIClient.shared.request(
            APIRouter.getInvoiceItems(invoiceID: bucketID, itemable_type: type),
            responseType: BucketItemsData.self,
            completion: completion
        )
    }
    
    static func deleteInvoiceItem(
        itemID : String ,
        InvoicelistID : String ,
        completion : @escaping (Result<(UpdateBucket , [AnyHashable : Any]) , APIError>) -> Void
    )
    {
        APIClient.shared.request(
            APIRouter.deleteInvoiceItem(itemID: itemID , InvoicelistID: InvoicelistID),
            responseType: UpdateBucket.self,
            completion: completion)
    }
    
    static func updateInvoiceItem(
        invoiceID : String,
        itemID : String,
        name: String,
        price : String,
        variation : String,
        unit : String,
        quantity : String,
        description : String,
        completion : @escaping (Result<(UpdateBucket,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.updateInvoiceItem(invoiceID : invoiceID , itemID: itemID, name: name, price: price, variation: variation, unit: unit, quantity: quantity, description: description),
            responseType: UpdateBucket.self,
            completion: completion)
    }
    
    static func addInvoiceItem(
        invoiceID : String,
        variation: String,
        name: String,
        price : String,
        unit : String,
        quantity : String,
        description : String,
        completion: @escaping (Result<(UpdateBucket,[AnyHashable : Any]), APIError>) -> Void
    ) {
        APIClient.shared.request(
            APIRouter.addInvoiceItems(invoiceID: invoiceID, variation: variation, name: name, price: price, unit: unit, quantity: quantity, description: description),
            responseType: UpdateBucket.self,
            completion: completion
        )
    }
    
}
