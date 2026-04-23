//
//  BucketItemsData.swift
//  Grocery Management
//
//  Created by mac on 04/06/2025.
//

struct BucketItemsData: Codable {
    let success: Bool?
    let message: String?
    let data: [Datum]?
    let metaAttributes: MetaAttributesVal?

    enum CodingKeys: String, CodingKey {
        case success, message, data
        case metaAttributes = "meta_attributes"
    }
}

// MARK: - Datum
struct Datum: Codable {
    let id: Int?
    let name: String?
    let price : Double?, quantity: Int?
    let unit, description, itemableType: String?
    let itemableID: Int?
    let variation: String?
    let isPurchased: Bool?
    let createdAt, updatedAt: String?
    let itemable: Itemables?

    enum CodingKeys: String, CodingKey {
        case id, name, price, quantity, unit, description , variation
        case itemableType = "itemable_type"
        case itemableID = "itemable_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isPurchased = "is_purchased"
        case itemable
    }
}

// MARK: - Itemable
struct Itemables: Codable {
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

// MARK: - MetaAttributes
struct MetaAttributesVal: Codable {
    let currentPage: Int?
    let nextPage, prevPage: Int?
    let totalPages, totalCount: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case nextPage = "next_page"
        case prevPage = "prev_page"
        case totalPages = "total_pages"
        case totalCount = "total_count"
    }
}
