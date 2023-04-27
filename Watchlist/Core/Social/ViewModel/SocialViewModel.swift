//
//  SocialViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/27/23.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class SocialViewModel: ObservableObject {
    @Published var currentUser: DBUser?
    @Published var allUsers: [DBUser] = []
    
    @Published var friendRequestIds: [String]?
    @Published var friendIds: [String]?
    
    @Published var friendRequests: [DBUser] = []
    @Published var friends: [DBUser] = []
    
    /// Watchlist Listener
    private var userListener: ListenerRegistration? = nil
    
    /// Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task {
            self.currentUser = try? await UserManager.shared.getUser()
        }
        if let currentUser {
            AnalyticsManager.shared.setUserProperty(value: currentUser.displayName, property: "displayName")
        }
        
        getAllUsers()
    }
    
    func getAllUsers() {
        Task {
            allUsers = try await UserManager.shared.getAllUsers()
        }
    }
    
    func convertUserIdToUser(userId: String) async throws -> DBUser {
        try await UserManager.shared.getUser(userId: userId)
    }
    
    func sendFriendRequest(userId: String) {
        Task {
            try await UserManager.shared.sendFriendRequest(to: userId)
        }
    }
    
    func cancelFriendRequest(userId: String) {
        Task {
            try await UserManager.shared.cancelFriendRequest(to: userId)
        }
    }
    
    func acceptFriendRequest(userId: String) {
        Task {
            try await UserManager.shared.acceptFriendRequest(from: userId)
        }
    }
    
    func declineFriendRequest(userId: String) {
        Task {
            try await UserManager.shared.declineFriendRequest(from: userId)
        }
    }
    
    func removeFriend(userId: String) {
        Task {
            try await UserManager.shared.removeFriend(friendUserId: userId)
        }
    }
    
    func addListenerForUser() throws {
        let (publisher, listener) = try UserManager.shared.addListenerForUser()
        self.userListener = listener
        
        publisher
            .sink(receiveCompletion: CrashlyticsManager.handleCompletition) { [weak self] updatedUser in
                guard let self else { return }
                self.friendRequestIds = updatedUser.friendRequests
                self.friendIds = updatedUser.friends
            }
            .store(in: &cancellables)
    }
}
