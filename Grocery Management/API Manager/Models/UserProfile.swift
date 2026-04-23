//
//  UserProfile.swift
//  Grocery Management
//
//  Created by mac on 16/06/2025.
//

import Foundation

// MARK: - UserProfile
struct UserProfile: Codable {
    let id: Int
    let provider, uid: String
    let allowPasswordChange: Bool
    let userName, email: String
    let phone: String?
    let gender: String
    let resetCode, resetCodeSentAt: String?
    let location : String?
    let createdAt, updatedAt: String?
    let setting: Setting?

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
        case setting
    }
}

// MARK: - Setting
struct Setting: Codable {
    let id, userID: Int?
    let sound, vibrate, pushNotification, emailNotification: Bool?
    let language: String?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case sound, vibrate
        case pushNotification = "push_notification"
        case emailNotification = "email_notification"
        case language
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
