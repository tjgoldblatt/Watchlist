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
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.displayName = auth.displayName
        self.photoUrl = auth.photoUrl
        self.dateCreated = Timestamp()
        self.friendRequests = nil
        self.friends = nil
    }

    init(userId: String,
         isAnonymous: Bool? = nil,
         email: String? = nil,
         photoUrl: String? = nil,
         dateCreated: Date? = nil,
         displayName: String? = nil,
         friendRequests: [String]? = nil,
         friends: [String]? = nil)
    {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.displayName = displayName
        self.dateCreated = Timestamp()
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
