//
//  SendCode.swift
//  Grocery Management
//
//  Created by mac on 23/05/2025.
//

struct SendCode: Codable {
    let success: Bool?
    let message : String?
    let error : String?
    enum CodingKeys: String, CodingKey {
        case success, message , error
    }
}
