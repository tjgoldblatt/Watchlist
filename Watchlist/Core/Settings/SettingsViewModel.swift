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
    @Published var authUser: AuthDataResultModel? = nil
    
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
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func delete() async throws {
        try await AuthenticationManager.shared.delete()
    }
    
    func linkGoogleAccount() async throws {
        let tokens = try await SignInWithGoogleHelper().signIn()
        self.authUser = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
    }
    
    func linkAppleAccount() async throws {
        let tokens = try await SignInWithAppleHelper().signIn()
        self.authUser = try await AuthenticationManager.shared.linkApple(tokens: tokens)
    }
}

extension SettingsViewModel {
    convenience init(forPreview: Bool = false) {
        self.init()
        if ApplicationHelper.isDebug, forPreview {
            // Hard code your mock data for the preview here
            self.authUser = AuthDataResultModel(uid: "abcds")
            self.authProviders = [.apple]
        }
    }
}
