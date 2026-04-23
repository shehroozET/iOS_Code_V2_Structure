//
//  createBucketItem.swift
//  Grocery Management
//
//  Created by mac on 04/06/2025.
//

import Foundation

// MARK: - BucketList
struct CreateBucketItems: Codable {
    let success: Bool?
    let message: String?
    let data: DataItems?
}

// MARK: - DataClass
struct DataItems: Codable {
    let id: Int?
    let name: String?
    let price : Double?, quantity: Int?
    let unit, description, itemableType: String?
    let itemableID: Int?
    let createdAt, updatedAt: String?
    let itemable: Itemable?

    enum CodingKeys: String, CodingKey {
        case id, name, price, quantity, unit, description
        case itemableType = "itemable_type"
        case itemableID = "itemable_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case itemable
    }
}

// MARK: - Itemable
struct Itemable: Codable {
    let id, userID: Int?
    let name, iconName, color, createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case name
        case iconName = "icon_name"
        case color
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
