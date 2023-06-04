//
//  DBUser.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/3/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct DBUser: Codable, Hashable, Identifiable {
    let userId: String
    var id: String { userId }
    let isAnonymous: Bool?
    let displayName: String?
    let email: String?
    let photoUrl: String?
    let dateCreated: Timestamp?
    let friendRequests: [String]?
    let friends: [String]?

    init(auth: AuthDataResultModel) {
        userId = auth.uid
        isAnonymous = auth.isAnonymous
        email = auth.email
        displayName = auth.displayName
        photoUrl = auth.photoUrl
        dateCreated = Timestamp()
        friendRequests = nil
        friends = nil
    }

    init(
        userId: String,
        isAnonymous: Bool? = nil,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated _: Date? = nil,
        displayName: String? = nil,
        friendRequests: [String]? = nil,
        friends: [String]? = nil
    ) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.displayName = displayName
        dateCreated = Timestamp()
        self.friends = friends
        self.friendRequests = friendRequests
    }

    enum CodingKeys: String, CodingKey {
        case userId
        case isAnonymous
        case email
        case photoUrl
        case dateCreated
        case displayName
        case friendRequests
        case friends
    }
}
