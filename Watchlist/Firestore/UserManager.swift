//
//  UserManager.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/8/23.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct DBUser: Codable {
    let userId: String
    let isAnonymous: Bool?
    let displayName: String?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.displayName = auth.displayName
        self.photoUrl = auth.photoUrl
        self.dateCreated = Date()
    }
    
    init(userId: String, isAnonymous: Bool? = nil, email: String? = nil, photoUrl: String? = nil, dateCreated: Date? = nil, displayName: String? = nil) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.displayName = displayName
        self.dateCreated = Date()
        
    }
    
    enum CodingKeys: CodingKey {
        case userId
        case isAnonymous
        case email
        case photoUrl
        case dateCreated
        case displayName
    }
}

final class UserManager {
    
    static let shared = UserManager()
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
        try await WatchlistManager.shared.createWatchlistForUser(userId: user.userId)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    func deleteUser(userId: String) async throws {
        try await userDocument(userId: userId).delete()
        try await MediaManager(userId: userId).deleteUserWatchlist()
        try await WatchlistManager.shared.deleteWatchlist(userId: userId)
    }
}
