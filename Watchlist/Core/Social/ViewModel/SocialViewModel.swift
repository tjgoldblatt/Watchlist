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
    
    @Published var usersWithFriendRequest: [DBUser] = []
    
    /// Watchlist Listener
    private var userListener: ListenerRegistration? = nil
    
    /// Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task { @MainActor in
            self.currentUser = try? await UserManager.shared.getUser()
        }
        if let currentUser {
            AnalyticsManager.shared.setUserProperty(value: currentUser.displayName, property: "displayName")
        }
        
        getAllUsers()
    }
    
    func getAllUsers() {
        Task { @MainActor in
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
    
    func getUsersWithFriendRequestFor(userId: String) {
        Task { @MainActor in
            self.usersWithFriendRequest = try await UserManager.shared.getUsersWithFriendRequestFor(userId: userId)
        }
    }
    
    func addListenerForUser() throws {
        let (publisher, listener) = try UserManager.shared.addListenerForUser()
        self.userListener = listener
        
        publisher
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: CrashlyticsManager.handleCompletition) { [weak self] updatedUser in
                guard let self else { return }
                self.friendRequestIds = updatedUser.friendRequests
                self.friendIds = updatedUser.friends
            }
            .store(in: &cancellables)
    }
}

#if DEBUG
extension SocialViewModel {
    convenience init(forPreview: Bool = true) {
        self.init()
        //Hard code your mock data for the preview here
        self.currentUser = DBUser(userId: "AB123", isAnonymous: false, email: "foo@gmail.com", displayName: "Steve", friendRequests: ["1a2HaoZWplUcDp7hxS1Ln6mkWmy1", "82rN4294VtT3gyXV8O0bV1I40mN2"], friends: [])
        self.friendRequests = [DBUser(userId: "aaa123", displayName: "John Smith"), DBUser(userId: "bbb456", displayName: "Maggie Jones")]
        self.friends = [DBUser(userId: "ccc789", displayName: "Jane Doe"), DBUser(userId: "ddd012", displayName: "Joe Schmoe")]
        
        self.allUsers = [DBUser(userId: "aaa123", displayName: "John Smith"), DBUser(userId: "bbb456", displayName: "Maggie Jones")]
    }
}
#endif
