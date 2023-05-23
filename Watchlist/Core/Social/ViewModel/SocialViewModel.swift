//
//  SocialViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/27/23.
//

import Combine
import FirebaseFirestore
import Foundation

@MainActor
final class SocialViewModel: ObservableObject {
    @Published var isLoaded: Bool = false

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
            allUsers = try await UserManager.shared.getAllUsers().sorted(by: { $0.displayName ?? "" < $1.displayName ?? "" })

            if !ApplicationHelper.isDebug {
                allUsers = allUsers
                    .filter { $0.userId != "82rN4294VtT3gyXV8O0bV1I40mN2" && $0.userId != "nPxpb3vGMOTV1kZd9gVYYd8WDbB2" }
            }
            isLoaded = true
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

    /// Returns all users that have pending friend request from userId
    func getUsersWithFriendRequestFor(userId: String) {
        Task { @MainActor in
            self.usersWithFriendRequest = try await UserManager.shared.getUsersWithFriendRequestFor(userId: userId)
        }
    }

    func addListenerForUser() throws {
        let (publisher, listener) = try UserManager.shared.addListenerForUser()
        userListener = listener

        publisher
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { [weak self] updatedUser in
                guard let self else { return }
                friendRequestIds = updatedUser.friendRequests
                friendIds = updatedUser.friends
            }
            .store(in: &cancellables)
    }
}

extension SocialViewModel {
    convenience init(forPreview: Bool = false) {
        self.init()
        if ApplicationHelper.isDebug, forPreview {
            // Hard code your mock data for the preview here
            currentUser = DBUser(
                userId: "AB123",
                isAnonymous: false,
                email: "foo@gmail.com",
                displayName: "Steve",
                friendRequests: ["1a2HaoZWplUcDp7hxS1Ln6mkWmy1", "82rN4294VtT3gyXV8O0bV1I40mN2"],
                friends: [])
            friendRequests = [
                DBUser(userId: "aaa123", displayName: "John Smith"),
                DBUser(userId: "bbb456", displayName: "Maggie Jones"),
            ]
            friends = [DBUser(userId: "ccc789", displayName: "Jane Doe"), DBUser(userId: "ddd012", displayName: "Joe Stevens")]

            allUsers = [
                DBUser(userId: "aaa123", displayName: "John Smith"),
                DBUser(userId: "bbb456", displayName: "Maggie Jones"),
            ]
        }
    }
}
