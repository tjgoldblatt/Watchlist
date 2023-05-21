//
//  UserWatchlist.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/3/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct UserWatchlist: Codable {
    let userId: String
    let displayName: String?
    let isTransferred: Timestamp?
    @ServerTimestamp var lastUpdated: Timestamp?

    init(userId: String, displayName: String?, lastUpdated: Timestamp?) {
        self.userId = userId
        self.displayName = displayName
        self.lastUpdated = lastUpdated
        isTransferred = nil
    }

    enum CodingKeys: String, CodingKey {
        case userId
        case displayName
        case isTransferred
        case lastUpdated
    }
}
