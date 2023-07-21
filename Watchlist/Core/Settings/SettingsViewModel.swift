//
//  SettingsViewModel.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/8/23.
//

import FirebaseAuth
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel?
    @Published var currentUser: DBUser?

    init() {
        loadAuthUser()
        loadAuthProviders()
    }

    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }

    func loadAuthUser() {
        do {
            authUser = try AuthenticationManager.shared.getAuthenticatedUser()
            Task {
                currentUser = try await UserManager.shared.getUser()
            }
        } catch {
            CrashlyticsManager.handleError(error: error)
        }
    }

    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }

    func delete() async throws {
        let currentUser = try await UserManager.shared.getUser()

        // Remove all pending friend requests
        let pendingFriendRequests = try await UserManager.shared.getUsersWithFriendRequestFor(userId: currentUser.userId)
        for pendingFriend in pendingFriendRequests {
            try await UserManager.shared.cancelFriendRequest(to: pendingFriend.userId)
        }

        // Remove all friends
        if let currentFriends = currentUser.friends {
            for friendID in currentFriends {
                try await UserManager.shared.removeFriend(friendUserId: friendID)
            }
        }

        try await AuthenticationManager.shared.delete()
    }

    func linkGoogleAccount() async throws {
        let tokens = try await SignInWithGoogleHelper().signIn()
        authUser = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
    }

    func linkAppleAccount() async throws {
        let tokens = try await SignInWithAppleHelper().signIn()
        authUser = try await AuthenticationManager.shared.linkApple(tokens: tokens)
    }
}

extension SettingsViewModel {
    convenience init(forPreview: Bool = false) {
        self.init()
        if ApplicationHelper.isDebug, forPreview {
            // Hard code your mock data for the preview here
            authUser = AuthDataResultModel(uid: "abcds")
            authProviders = [.apple]
        }
    }
}
