//
//  SettingsViewModel.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/8/23.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    
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
    
//    func resetPassword() async throws {
//        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
//
//        guard let email = authUser.email else {
//            // create custom errors
//            throw URLError(.fileDoesNotExist)
//        }
//
//        try await AuthenticationManager.shared.resetPassword(email: email)
//    }
    
    // User needs to reauthenticate again, have a pop up that says in order to update your email you need to sign back into your account
//    func updateEmail() async throws {
//        let email = "hello123@gmail.com"
//        try await AuthenticationManager.shared.updateEmail(email: email)
//    }
    
//    // User needs to reauthenticate again, have a pop up that says in order to update your password you need to sign back into your account
//    func updatePassword() async throws {
//        let password = "hello123"
//        try await AuthenticationManager.shared.updatePassword(password: password)
//    }
    
    func linkGoogleAccount() async throws {
        let tokens = try await SignInWithGoogleHelper().signIn()
        self.authUser = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
    }
    
    func linkAppleAccount() async throws {
        let tokens = try await SignInWithAppleHelper().signIn()
        self.authUser = try await AuthenticationManager.shared.linkApple(tokens: tokens)
    }
}
