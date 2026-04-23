//
//  API Error.swift
//  Grocery Management
//
//  Created by mac on 19/05/2025.
//

import Foundation

enum APIError: Error {
    case network(description: String)
    case server(message: String)
    case parsing
    case unknown
    case backendError(data: Data)
    
    var localizedDescription: String {
        switch self {
        case .network(let desc): return "Network error: \(desc)"
        case .server(let msg): return "Server error: \(msg)"
        case .parsing: return "Failed to parse response"
        case .unknown: return "Unknown error"
        case .backendError(let data):
            if let apiError = try? JSONDecoder().decode(RegistrationResponse.self, from: data),
               let messages = apiError.errors?.fullMessages {
                return messages.joined(separator: "\n")
            }
            if let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data),
               let error = apiError.errors{
                return error.joined(separator: "\n")
            }
            return "Data corrupted : Failed to parse response"
        }
    }
}
