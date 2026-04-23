//
//  Bucketlist.swift
//  Grocery Management
//
//  Created by mac on 26/05/2025.
//

import Foundation

// MARK: - BucketList
struct BucketList: Codable,Equatable {
    let success: Bool?
    let message: String?
    let data: [ListData]?
    let metaAttributes: MetaAttributes?

    enum CodingKeys: String, CodingKey {
        case success, message, data
        case metaAttributes = "meta_attributes"
    }
}

// MARK: - ListData
struct ListData : Codable,Equatable {
    let id, userID: Int?
    let name, iconName, color, createdAt: String?
    let updatedAt: String?
    let items: [ItemsBucket]?
    let user: UserInfo?
    let shareList : [SharedList]?
    let ownership : String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case name
        case iconName = "icon_name"
        case color
        case createdAt = "created_at"
        case shareList = "shared_lists"
        case updatedAt = "updated_at"
        case items, user , ownership
    }
}

// MARK: - SharedList
struct SharedList: Codable, Equatable {
    let id: Int?
    let shareableType: String?
    let sharedTo: SharedTo?

    enum CodingKeys: String, CodingKey {
        case id
        case shareableType = "shareable_type"
        case sharedTo = "shared_to"
    }
}

// MARK: - SharedTo
struct SharedTo: Codable, Equatable{
    let id: Int?
    let userName, email: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userName = "user_name"
        case email
    }
}

// MARK: - UserInfomation
struct UserInfo : Codable,Equatable{
    let id: Int?
    let provider, uid: String?
    let allowPasswordChange: Bool?
    let userName, email: String?
    let phone: String?
    let gender: String?
    let resetCode, location, resetCodeSentAt: String?
    let createdAt, updatedAt: String?
    
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

// MARK: - MetaAttributes
struct MetaAttributes: Codable,Equatable {
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
struct ItemsBucket: Codable, Equatable{
    let id: Int?
    let name: String?
    let price : Double?, quantity: Int?
    let unit, description, itemableType: String?
    let itemableID: Int?
    let variation: String?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, price, quantity, unit, description , variation
        case itemableType = "itemable_type"
        case itemableID = "itemable_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
    }

    public var hashValue: Int {
            return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
    }

    public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
            return nil
    }

    required init?(stringValue: String) {
            key = stringValue
    }

    var intValue: Int? {
            return nil
    }

    var stringValue: String {
            return key
    }
}

