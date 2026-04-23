//
//  CreateBucket.swift
//  Grocery Management
//
//  Created by mac on 29/05/2025.
//

import Foundation

// MARK: - BucketList
struct CreateBucket: Codable {
    var success: Bool? = nil
    var message: String? = nil
    var data: CreateBucketData? = nil
}

// MARK: - DataClass
struct CreateBucketData: Codable {
    let id, userID: Int?
    let name, iconName, color, createdAt: String?
    let updatedAt: String?
    let items: [String]? = nil
    let user: User?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case name
        case iconName = "icon_name"
        case color
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case items, user
    }
}

// MARK: - User
struct User: Codable {
    let id: Int?
    let provider, uid: String?
    let allowPasswordChange: Bool?
    let userName, email, phone, gender: String?
    let resetCode, location: String?
    let resetCodeSentAt, createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, provider, uid
        case allowPasswordChange = "allow_password_change"
        case userName = "user_name"
        case email, phone, gender
        case resetCode = "reset_code"
        case location
        case resetCodeSentAt = "reset_code_sent_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
