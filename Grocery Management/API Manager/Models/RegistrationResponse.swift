//
//  RegistrationResponse.swift
//  Grocery Management
//
//  Created by mac on 21/05/2025.
//

import Foundation

// MARK: - LoginResponse
struct RegistrationResponse: Codable {
    let status: String?
    let data: RegistrationData?
    let errors: Errors?
}

// MARK: - DataClass
struct RegistrationData: Codable {
    let id: Int?
    let provider, uid: String?
    let allowPasswordChange: Bool?
    let userName, email: String?
    let phone: String?
    let gender: String?
    let resetCode , location, resetCodeSentAt, createdAt: String?
    let updatedAt: String?

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

// MARK: - Errors
struct Errors: Codable {
    let fullMessages: [String]

    enum CodingKeys: String, CodingKey {
        case fullMessages = "full_messages"
    }
}

