//
//  APIErrorResponse.swift
//  Grocery Management
//
//  Created by mac on 26/05/2025.
//

import Foundation

// MARK: - LoginResponse
struct APIErrorResponse: Codable {
    let success: Bool?
    let errors: [String]?
}
