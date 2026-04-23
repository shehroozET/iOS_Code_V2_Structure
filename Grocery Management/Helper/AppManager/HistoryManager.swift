//
//  History.swift
//  Grocery Management
//
//  Created by mac on 20/06/2025.
//

import Foundation

struct HistoryItem: Codable, Equatable {
    let id: Int
    let name: String
    let date: String
    let shareList : [SharedList]
    let totalItems: Int
    let iconName : String
    let color : String
    
    static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        return lhs.id == rhs.id
    }
}

class HistoryManager {
    static let shared = HistoryManager()

    
    private let key = "history_items"
    
    private init() {}
    
    func getHistory() -> [HistoryItem] {
        if let uid = TokenManager.shared.uid {
            guard let data = UserDefaults.standard.data(forKey: key+uid),
                  let items = try? JSONDecoder().decode([HistoryItem].self, from: data) else {
                return []
            }
            return items
        }
        return []
       
    }
    
    func saveHistory(_ items: [HistoryItem]) {
        if let uid = TokenManager.shared.uid {
            if let data = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(data, forKey: key+uid)
            }
        }
    }
    
    func addToHistory(_ newItem: HistoryItem) {
        var currentHistory = getHistory()
        
        
        currentHistory.removeAll { $0.id == newItem.id }
        
        currentHistory.insert(newItem, at: 0)
        
        if currentHistory.count > 3 {
            currentHistory = Array(currentHistory.prefix(3))
        }
        
        saveHistory(currentHistory)
    }
    func deleteFromHistory(by id: Int) {
        var currentHistory = getHistory()
        currentHistory.removeAll { $0.id == id }
        saveHistory(currentHistory)
    }
}

