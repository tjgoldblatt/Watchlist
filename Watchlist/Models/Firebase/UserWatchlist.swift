//
//  UserWatchlist.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/3/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserWatchlist: Codable {
	let userId: String
	let displayName: String?
	let isTransferred: Timestamp?
	@ServerTimestamp var lastUpdated: Timestamp?
	
	init(userId: String, displayName: String?, lastUpdated: Timestamp?) {
		self.userId = userId
		self.displayName = displayName
		self.lastUpdated = lastUpdated
		self.isTransferred = nil
	}
	
	enum CodingKeys: String, CodingKey {
		case userId
		case displayName
		case isTransferred
		case lastUpdated
	}
}
