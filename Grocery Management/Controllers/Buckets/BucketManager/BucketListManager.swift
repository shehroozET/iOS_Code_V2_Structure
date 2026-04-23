//
//  BucketListManager.swift
//  Grocery Management
//
//  Created by mac on 27/06/2025.
//

import Foundation

class BucketListManager {
    static let shared = BucketListManager()
    
    private init() {}

    var sharedListData: [SharedList] = []

    func getLatestData(completion: ((Bool) -> Void)? = nil){
        NotificationCenter.default.post(name: .sharedListUpdated, object: nil)
    }
}
