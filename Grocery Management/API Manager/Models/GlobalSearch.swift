//
//  GlobalSearch.swift
//  Grocery Management
//
//  Created by mac on 17/06/2025.
//

import Foundation

// MARK: - UserProfile
struct GlobalSearch: Codable  {
    let success: Bool?
    let data: [GSearchData]?
}

// MARK: - DataClass
struct GSearchData: Codable  {
    let id, userID: Int?
    let name, iconName, color, createdAt: String?
    let item_type,updatedAt: String?
    let ownership : String?
    let items: [Item]?
    let shareList : [SharedList]?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case name
        case iconName = "icon_name"
        case color
        case ownership
        case item_type
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case shareList = "shared_lists"
        case items
    }
}

// MARK: - Item
struct Item: Codable {
    let id: Int?
    let name: String?
    let price : Double?, quantity: Int?
    let unit, description: String?
    let itemableType: String?
    let itemableID: Int?
    let createdAt, updatedAt: String?
    let variation: String?

    enum CodingKeys: String, CodingKey {
        case id, name, price, quantity, unit, description
        case itemableType = "itemable_type"
        case itemableID = "itemable_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case variation
    }
}

