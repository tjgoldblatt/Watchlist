//
//  UserManager.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/8/23.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestore
import Combine

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
         friends: [String]? = nil
    ) {
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

/// This class manages the user data in Firestore. It provides functions to create, update, and delete user data.
final class UserManager {
    
    static let shared = UserManager()
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("users")
    
    /// Returns the document reference for the authenticated user.
    private func userDocument() throws -> DocumentReference {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        return userCollection.document(authDataResult.uid)
    }
    
    /// Creates a new user in Firestore and creates a watchlist for the user.
    /// - Parameter user: The user data to be saved in Firestore.
    func createNewUser(user: DBUser) async throws {
        try userDocument().setData(from: user, merge: true)
        try await WatchlistManager.shared.createWatchlistForUser()
    }
    
    /// Updates the user data in Firestore after linking with a new authentication provider.
    /// - Parameter authDataResultModel: The authentication data result model.
    func updateUserAfterLink(authDataResultModel: AuthDataResultModel) async throws {
        let updatedDBUser = DBUser(auth: authDataResultModel)
        try userDocument().setData(from: updatedDBUser, merge: true)
    }
    
    /// Returns the user data for the authenticated user.
    func getUser() async throws -> DBUser {
        return try await userDocument().getDocument(as: DBUser.self)
    }
    
    /// Deletes the user data and the watchlist for the authenticated user.
    func deleteUser() async throws {
        try await WatchlistManager.shared.deleteWatchlist()
        try await userDocument().delete()
    }
    
    /// Updates the display name for the authenticated user in Firestore.
    /// - Parameter displayName: The new display name.
    func updateDisplayNameForUser(displayName: String) async throws {
        let data: [String:Any] = [
            DBUser.CodingKeys.displayName.rawValue : displayName
        ]
        
        try await userDocument().updateData(data)
    }
}

// MARK: - Social
extension UserManager {
    // TODO: Send push notification when a user adds another user OR a user accepts another users friend request
    private func userDocument(userId: String) throws -> DocumentReference {
        return userCollection.document(userId)
    }
    
    func getAllUsers() async throws -> [DBUser] {
        try await userCollection
            .whereField(DBUser.CodingKeys.isAnonymous.rawValue, isEqualTo: false)
            .getDocuments(as: DBUser.self)
    }
    
    /// Returns the user data for the given user id.
    func getUser(userId: String) async throws -> DBUser {
        return try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    func addListenerForUser() throws -> (AnyPublisher<DBUser, Error>, ListenerRegistration) {
        try userDocument()
            .addSnapshotListener(as: DBUser.self)
    }
    
    func sendFriendRequest(to anotherUserId: String) async throws {
        let currentUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        let data: [String:Any] = [
            DBUser.CodingKeys.friendRequests.rawValue : FieldValue.arrayUnion([currentUser.uid])
        ]
        
        try await userDocument(userId: anotherUserId).updateData(data)
    }
    
    func cancelFriendRequest(to anotherUserId: String) async throws {
        let currentUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        let otherUserData: [String:Any] = [
            DBUser.CodingKeys.friendRequests.rawValue : FieldValue.arrayRemove([currentUser.uid])
        ]
        
        try await userDocument(userId: anotherUserId).updateData(otherUserData)
    }
    
    /// Removes a friend request from the current user's friend requests list.
    /// - Parameters:
    ///   - anotherUserId: The user ID of the friend request to be removed.
    /// - Throws: An error of type `Error` if the operation fails.
    func removeFriendRequest(from anotherUserId: String) async throws {
        let currentUserData: [String:Any] = [
            DBUser.CodingKeys.friendRequests.rawValue : FieldValue.arrayRemove([anotherUserId])
        ]
        
        try await userDocument().updateData(currentUserData)
    }
    
    func acceptFriendRequest(from anotherUserId: String) async throws {
        try await removeFriendRequest(from: anotherUserId)
        try await addFriend(friendUserId: anotherUserId)
    }
    
    func denyFriendRequest(from anotherUserId: String) async throws {
        try await removeFriendRequest(from: anotherUserId)
    }
    
    func addFriend(friendUserId: String) async throws {
        // Add friend id to current user friends list
        let currentUserData: [String:Any] = [
            DBUser.CodingKeys.friends.rawValue : FieldValue.arrayUnion([friendUserId])
        ]
        
        try await userDocument().updateData(currentUserData)
        
        // Add current user id to new friend's list
        let currentUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        let friendUserData: [String:Any] = [
            DBUser.CodingKeys.friends.rawValue : FieldValue.arrayUnion([currentUser.uid])
        ]
        
        try await userDocument().updateData(friendUserData)
    }
}
