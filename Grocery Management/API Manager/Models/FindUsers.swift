//
//  FindFriends.swift
//  Grocery Management
//
//  Created by mac on 26/06/2025.
//

import Foundation

// MARK: - FindUsers
struct FindUsers: Codable {
    let success: Bool?
    let data: [UsersFound]?
}

// MARK: - Datum
struct UsersFound: Codable {
    let id: Int?
    let email, userName: String?
    let pictureURL: String?

    enum CodingKeys: String, CodingKey {
        case id, email
        case userName = "user_name"
        case pictureURL = "picture_url"
    }
}
