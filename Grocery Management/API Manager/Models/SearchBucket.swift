//
//  SearchBucket.swift
//  Grocery Management
//
//  Created by mac on 13/06/2025.
//


import Foundation

// MARK: - SearchBucket
struct SearchBucket: Codable {
    let success: Bool
    let data: [SearchData]
}

// MARK: - Datum
struct SearchData: Codable {
    let id: Int
    let name, createdAt: String
    let itemsCount: Int

    enum CodingKeys: String, CodingKey {
        case id, name
        case createdAt = "created_at"
        case itemsCount = "items_count"
    }
}
