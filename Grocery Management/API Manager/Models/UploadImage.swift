//
//  UploadImage.swift
//  Grocery Management
//
//  Created by mac on 01/07/2025.
//

import Foundation

// MARK: - UploadImage
struct UploadImage: Codable {
    let success: Bool?
    let message: String?
    let data: ImageData?
}

// MARK: - ImageData
struct ImageData: Codable {
    let email, provider, uid: String?
    let id: Int?
    let allowPasswordChange: Bool?
    let userName, phone, gender: String?
    let resetCode: String? = nil
    let location: String?
    let resetCodeSentAt: String? = nil
    let createdAt, updatedAt: String?
    let pictureURL: String?

    enum CodingKeys: String, CodingKey {
        case email, provider, uid, id
        case allowPasswordChange = "allow_password_change"
        case userName = "user_name"
        case phone, gender
        case resetCode = "reset_code"
        case location
        case resetCodeSentAt = "reset_code_sent_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case pictureURL = "picture_url"
    }
}
