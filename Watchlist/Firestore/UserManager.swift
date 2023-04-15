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
    let dateCreated: Timestamp?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.isAnonymous = auth.isAnonymous
        self.email = auth.email
        self.displayName = auth.displayName
        self.photoUrl = auth.photoUrl
        self.dateCreated = Timestamp()
    }
    
    init(userId: String, isAnonymous: Bool? = nil, email: String? = nil, photoUrl: String? = nil, dateCreated: Date? = nil, displayName: String? = nil) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoUrl
        self.displayName = displayName
        self.dateCreated = Timestamp()
    }
    
    enum CodingKeys: String, CodingKey {
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
    
    private func userDocument() throws -> DocumentReference {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        return userCollection.document(authDataResult.uid)
    }
    
    func createNewUser(user: DBUser) async throws {
        try userDocument().setData(from: user, merge: true)
        try await WatchlistManager.shared.createWatchlistForUser()
    }
    
    func updateUserAfterLink(authDataResultModel: AuthDataResultModel) async throws {
        let updatedDBUser = DBUser(auth: authDataResultModel)
        try userDocument().setData(from: updatedDBUser, merge: true)
    }
    
    func getUser() async throws -> DBUser {
        try await userDocument().getDocument(as: DBUser.self)
    }
    
    func deleteUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        try await userDocument().delete()
        try await WatchlistManager.shared.deleteWatchlist(userId: authDataResult.uid)
    }
    
    func getDisplayNameForUser() async throws -> String? {
        let user = try await getUser()
        return user.displayName
    }
    
    func updateDisplayNameForUser(displayName: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.displayName.rawValue : displayName
        ]
        
        try await userDocument().updateData(data)
    }
}
