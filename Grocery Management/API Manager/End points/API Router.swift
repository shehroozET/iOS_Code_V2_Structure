//
//  API Router.swift
//  Grocery Management
//
//  Created by mac on 19/05/2025.
//

import Alamofire

enum APIRouter: URLRequestConvertible {
    // MARK: - Authentication APIs
    case login(email: String, password: String)
    case googleSignIn(email: String, name: String)
    case register( user_name : String, email : String ,  password: String , password_confirmation : String)
    case sendCode(email : String)
    case verifyCode(email : String , code : String)
    case updatePassword(email : String , code : String , password : String , password_confirmation : String)
    
    // MARK: - Bucket APIs
    case getBucketList
    case createBucketList(userID: String, bucketName: String, color: String, icon: String, items: [BucketItem])
    case deleteBucket(bucketID : String)
    case updateBucket(bucketID : String , userID : String , bucketName : String , color : String , icon : String)
    case getBucketItems(bucketID : String , itemable_type : String)
    case addBucketItems(bucketID : String , variation : String , name : String , price : String , unit : String , quantity : String , description : String)
    case updateBucketItem(bucketID : String , itemID : String , name : String , price : String , variation : String ,  unit : String , quantity : String , description : String)
    case deleteSelectedBucketItems(bucketID : String , items : [DeletedItems])
    case deleteBucketItem(itemID : String , bucketlistID : String)
    case searchBucketList(filterType : String , searchString : String , startDate : String , endDate : String , bucket_type : String)
    case markAsPurchased(itemId : String , is_purchased : Bool)
    case shareBucket(userIDToShareBucket : String , bucketID : String)
    case deleteSharedBucket(bucketID : String)
    
    // MARK: - Settings APIs
    case getUserProfile
    case updateProfile(username : String , email : String , phone : String , gender : String , location : String , currency : String)
    case updateSettings(switch_sound : Bool , switch_vibrate : Bool , switch_push_notification : Bool , switch_email_notification : Bool)
    case changePassword(currentPassword : String , NewPassword : String , confirmPassword : String )
    
    // MARK: - Global Search API
    case globalSearch(filterKey : String , filterType : String  )
    
    // MARK: - Invoice APIs
    case getInvoiceList
    case createInvoiceList(userID : String , invoiceName : String , color : String , icon : String, item : [ScannedItem])
    case deleteInvoice(invoiceID : String)
    case updateInvoice(invoiceID : String , userID : String , invoiceName : String , color : String , icon : String)
    case createAIInvoiceItems(invoiceID : String , userID : String , invoiceName : String , color : String , icon : String , item : [ScannedItem])
    
    case getInvoiceItems(invoiceID : String , itemable_type : String)
    case addInvoiceItems(invoiceID : String , variation : String , name : String , price : String , unit : String , quantity : String , description : String)
    case updateInvoiceItem(invoiceID : String , itemID : String , name : String , price : String , variation : String ,  unit : String , quantity : String , description : String)
    case deleteInvoiceItem(itemID : String , InvoicelistID : String)
    case searchInvoiceList(filterType : String , searchString : String , startDate : String , endDate : String)
    case searchUser(email : String)
    case deleteSelectedItems(listID : String , items : [DeletedItems])
    
    // MARK: - HTTPMethod
    var method: HTTPMethod {
        switch self {
            // MARK: - Authentication APIs
        case .login: return .post
        case .googleSignIn: return .post
        case .register: return .post
        case .sendCode: return .post
        case .verifyCode: return .post
        case .updatePassword: return .post
            
            // MARK: - Bucket APIs
        case .getBucketList: return .get
        case .createBucketList: return .post
        case .deleteBucket: return .delete
        case .updateBucket: return .patch
        case .getBucketItems: return .get
        case .addBucketItems: return .post
        case .updateBucketItem: return .patch
        case .deleteBucketItem: return .delete
        case .searchBucketList: return .get
            
            // MARK: - Settings APIs
        case .getUserProfile: return .get
        case .updateProfile: return .put
        case .updateSettings: return .put
        case .changePassword: return .put
            // MARK: - Global search APIs
        case .globalSearch: return .get
            
            // MARK: - Invoice APIs
        case .getInvoiceList: return .get
        case .createInvoiceList: return .post
        case .deleteInvoice: return .delete
        case .updateInvoice: return .patch
        case .createAIInvoiceItems: return .patch
        case .getInvoiceItems: return .get
        case .addInvoiceItems: return .post
        case .updateInvoiceItem: return .patch
        case .markAsPurchased: return .patch
        case .deleteInvoiceItem: return .delete
        case .searchInvoiceList: return .get
        case .searchUser: return .get
        case .shareBucket: return .post
        case .deleteSharedBucket: return .delete
        case .deleteSelectedItems: return .patch
        case .deleteSelectedBucketItems: return .patch
        }
    }
    
    // MARK: - Path
    var path: String {
        switch self {
        case .login: return "/auth/sign_in"
        case .googleSignIn: return "/auth/login_with_google"
        case .register: return "/auth"
        case .sendCode: return "/auth/password/send_code"
        case .verifyCode: return "/auth/password/verify_code"
        case .updatePassword: return "/auth/password/update"
            
            // MARK: - Bucket APIs
        case .getBucketList: return "/api/v1/user/bucket_lists"
        case .createBucketList: return "/api/v1/user/bucket_lists"
        case .deleteBucket(let bucketID):
            return "/api/v1/user/bucket_lists/\(bucketID)"
        case .updateBucket(let bucketID, _, _, _, _ ):
            return "/api/v1/user/bucket_lists/\(bucketID)"
        case .getBucketItems(let bucketID , _):
            return "/api/v1/user/bucket_lists/\(bucketID)/items"
        case .addBucketItems(let bucketID , _ , _ , _ , _ , _ , _):
            return "/api/v1/user/bucket_lists/\(bucketID)/items"
        case .updateBucketItem(let bucketID , let itemID, _ , _ , _ , _ , _ , _):
            return "/api/v1/user/items/\(itemID)?bucket_list_id=\(bucketID)"
        case .deleteBucketItem(let itemID , _ ):
            return "/api/v1/user/items/\(itemID)"
        case .markAsPurchased(let itemID , _ ):
            return "/api/v1/user/items/\(itemID)"
        case .searchBucketList(_ , _ , _ , _ , _):
            return "/api/v1/user/bucket_lists/filter_list"
            
            // MARK: - Settings APIs
        case .getUserProfile:
            return "/api/v1/user/profiles"
        case .updateProfile:
            return "/api/v1/user/profiles"
        case .updateSettings:
            return "/api/v1/user/settings"
        case .changePassword:
            return "/auth/password/change_password"
        case .globalSearch:
            return "/api/v1/user/bucket_lists/filter_list"
            
            // MARK: - Invoice APIs
        case .getInvoiceList:
            return "/api/v1/user/grocery_invoices"
        case .createInvoiceList: 
            return "/api/v1/user/grocery_invoices"
        case .deleteInvoice(let invoiceID):
            return "/api/v1/user/grocery_invoices/\(invoiceID)"
        case .updateInvoice(let invoiceID, _, _, _, _ ):
            return "/api/v1/user/grocery_invoices/\(invoiceID)"
        case .createAIInvoiceItems(let invoiceID, _, _, _, _ , _):
            return "/api/v1/user/grocery_invoices/\(invoiceID)"
        case .getInvoiceItems(let invoiceID , _):
            return "/api/v1/user/grocery_invoices/\(invoiceID)/items"
        case .addInvoiceItems(let invoiceID , _ , _ , _ , _ , _ , _):
            return "/api/v1/user/grocery_invoices/\(invoiceID)/items"
        case .updateInvoiceItem(_ , let itemID, _ , _ , _ , _ , _ , _):
            return "/api/v1/user/items/\(itemID)"
        case .deleteInvoiceItem(let itemID , _ ):
            return "/api/v1/user/items/\(itemID)"
        case .searchInvoiceList(_ , _ , _ , _):
            return "/api/v1/user/bucket_lists/filter_list"
        case .searchUser(_):
            return "/api/v1/user/profiles/filter_users"
        case .shareBucket(_, _):
            return "/api/v1/user/shared_lists"
        case .deleteSharedBucket(let bucketID):
            return "/api/v1/user/shared_lists/\(bucketID)"
        case .deleteSelectedItems(let listID , _):
            return "/api/v1/user/grocery_invoices/\(listID)"
        case .deleteSelectedBucketItems(let bucketID , _):
            return "/api/v1/user/bucket_lists/\(bucketID)"
        }
    }
    
    // MARK: - Parameters
    var parameters: Parameters? {
        switch self {
        case .login(let email, let password):
            return ["email": email, "password": password]
        case .googleSignIn(let email, let name):
            return ["email": email, "user_name": name]
        case .register(let user_name, let email , let password, let password_confirmation):
            return ["email": email, "password": password , "password_confirmation" : password_confirmation , "user_name" : user_name]
        case .sendCode(let email):
            return ["email": email]
        case .verifyCode(let email , let code):
            return ["email": email , "code" : code]
        case .updatePassword(let email, let code, let password , let password_confirmation):
            return ["email": email, "code": code , "password" : password , "password_confirmation" : password_confirmation]
            
            // MARK: - Bucket APIs
        case .createBucketList(let userID, let bucketName, let color , let icon , let items):
            let itemDicts = items.map { item in
                   return [
                       "name": item.name,
                       "price": item.price,
                       "quantity": item.quantity,
                       "unit": item.unit,
                       "description": item.description
                   ]
               }
            return ["bucket_list": ["user_id" : userID, "name": bucketName , "color" : color , "icon_name" : icon , "items_attributes":  itemDicts]]
        case .updateBucket(_, let userID, let bucketName, let color , let icon):
            return ["bucket_list": ["user_id" : userID, "name": bucketName , "color" : color , "icon_name" : icon]]
        case .getBucketItems(_, let itemable_type):
            return ["itemable_type" : itemable_type]
        case .addBucketItems(_ , let variation , let name , let price , let unit , let quantity , let description):
            return ["item": ["name" : name , "price" : price, "unit" : unit , "quantity" : quantity , "variation" : variation , "description" : description] , "itemable_type" : "bucket_list"]
        case .updateBucketItem(_ , _ , let name , let price , let variation , let unit , let quantity , let description):
            return ["item": ["name" : name , "price" : price, "variation" : variation , "unit" : unit , "quantity" : quantity , "description" : description] , "itemable_type" : "bucket_list"]
        case .deleteBucketItem(_, let bucketlistID):
            return ["itemable_type" : "bucket_list" , "bucket_list_id": bucketlistID]
        case .markAsPurchased(_, let isPurchased):
            return ["item": ["is_purchased": isPurchased]]
        case .searchBucketList(let filterType , let searchString , let startDate , let endDate , let bucket_type):
            return ["filter_type" : filterType , "name" : searchString , "start_date" : startDate , "end_date" : endDate , "bucket_type" : bucket_type]
            
        case .searchUser(let email):
            return ["email" : email]
            
            
            // MARK: - Profile APIs
        case .updateProfile(let username , let email , let phone , let gender , let location , let currency):
            return  ["user": ["user_name" : username , "email" : email, "phone" : phone , "gender" : gender , "location" : location , "currency" : currency ] ]
        case .updateSettings(let sound , let vibrate , let push_notification , let email_notification):
            return  ["setting": ["sound" : sound , "vibrate" : vibrate, "push_notification" : push_notification , "email_notification" : email_notification ] ]
        case .changePassword(let currentPassword , let newPassword , let confirmPassword):
            return  ["current_password" : currentPassword , "new_password" : newPassword, "confirm_password" : confirmPassword ]
            
            // MARK: - Global Search APIs
        case .globalSearch(let filterKey, let filterType):
            return ["name" : filterKey , "filter_type" : filterType] // types : "bucket_list" , "grocery_invoice"
            
            
            // MARK: - Invoice APIs
        case .createInvoiceList(let userID, let invoiceName, let color , let icon , let items):
            let itemDicts = items.map { item in
                   return [
                       "name": item.name,
                       "price": item.price,
                       "quantity": item.quantity
                   ]
               }
            return ["grocery_invoice": ["user_id" : userID, "name": invoiceName , "color" : color , "icon_name" : icon , "items_attributes":  itemDicts]]
        case .updateInvoice(_, let userID, let invoiceName, let color , let icon):
            return ["grocery_invoice": ["user_id" : userID, "name": invoiceName , "color" : color , "icon_name" : icon]]
        case .createAIInvoiceItems(_, let userID, let invoiceName, let color , let icon , let items):
            let itemDicts = items.map { item in
                   return [
                       "name": item.name,
                       "price": item.price,
                       "quantity": item.quantity
                   ]
               }
            return ["grocery_invoice": ["user_id" : userID, "name": invoiceName , "color" : color , "icon_name" : icon , "items_attributes":  itemDicts]]
        case .getInvoiceItems(_, _):
            return ["itemable_type" : "GroceryInvoice"]
        case .addInvoiceItems(_ , let variation , let name , let price , let unit , let quantity , let description):
            return ["item": ["name" : name , "price" : price, "unit" : unit , "quantity" : quantity , "variation" : variation , "description" : description] , "itemable_type" : "GroceryInvoice"]
        case .updateInvoiceItem(_ , _ , let name , let price , let variation , let unit , let quantity , let description):
            return ["item": ["name" : name , "price" : price, "variation" : variation , "unit" : unit , "quantity" : quantity , "description" : description] ]
        case .searchInvoiceList(let filterType , let searchString , let startDate , let endDate):
            return ["filter_type" : filterType , "name" : searchString , "start_date" : startDate , "end_date" : endDate]
        case .shareBucket(let userIDToShareBucket, let bucketID):
            return [
                "shared_list": [
                  "shareable_type": "bucket_list",
                  "shareable_id": bucketID,
                  "shared_to_id": userIDToShareBucket
                ]
              ]
        case .deleteSelectedItems(_ , let items):
            let itemDicts = items.map { item in
                   return [
                       "id": item.id,
                       "_destroy": true
                   ]
               }
            return ["grocery_invoice" : ["items_attributes" : itemDicts]]
        case .deleteSelectedBucketItems(_ , let items):
            let itemDicts = items.map { item in
                   return [
                       "id": item.id,
                       "_destroy": true
                   ]
               }
            return ["bucket_list" : ["items_attributes" : itemDicts]]
        default: return nil
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        
        let baseURL = Config.shared.configuration.api
        let fullPath = baseURL +  path
        let url = URL(string: fullPath )
      
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = method.rawValue
        
        // Headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = TokenManager.shared.token {
            urlRequest.setValue("\(token)", forHTTPHeaderField: "Access-Token")
        }
        if let client = TokenManager.shared.client {
            urlRequest.setValue(client, forHTTPHeaderField: "Client")
        }
        if let uid = TokenManager.shared.uid {
            urlRequest.setValue(uid, forHTTPHeaderField: "Uid")
        }
        
        
        // Encoding
        let encoding: ParameterEncoding = {
            switch method {
            case .get: return URLEncoding.default
            default: return JSONEncoding.default
            }
        }()
        
        return try encoding.encode(urlRequest, with: parameters)
    }
}
