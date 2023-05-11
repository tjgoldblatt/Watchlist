//
//  AuthenticationManager.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/6/23.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let displayName: String?
    let isAnonymous: Bool
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.displayName = user.displayName
        self.isAnonymous = user.isAnonymous
    }
    
    init(
    uid: String = "",
    email: String? = nil,
    photoUrl: String? = nil,
    displayName: String? = nil,
    isAnonymous: Bool = false
    ) {
        self.uid = uid
        self.email = email
        self.photoUrl = photoUrl
        self.displayName = displayName
        self.isAnonymous = isAnonymous
    }
}

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "apple.com"
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() { }
    
    // not reaching out to server, only reaching out locally
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseError.getAuthenticatedUser
        }
        CrashlyticsManager.setUserId(userId: user.uid)
        
        AnalyticsManager.shared.setUserId(userId: user.uid)
        AnalyticsManager.shared.setUserProperty(value: user.isAnonymous.description, property: "isAnonymous")
        
        return AuthDataResultModel(user: user)
    }

    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw FirebaseError.getProviders
        }
        
        var providers: [AuthProviderOption] = []
        
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        
        return providers
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseError.deleteUser
        }
        
        try await UserManager.shared.deleteUser()
        try await user.delete()
    }
    
    /// To delete a specific user from the DB, still need to remove them from the Auth Tab in FireBase.
    /// Used for deleting Apple testers when pushing to TestFlight
    /// - Parameter userId: userId of Apple Tester
    func delete(userId: String) async throws {
        try await UserManager.shared.deleteUser(userId: userId)
    }
}

// MARK: - Sign In SSO
extension AuthenticationManager {
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResult) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(authCredential: credential)
    }
    
    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await signIn(authCredential: credential)
    }
    
    func signIn(authCredential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: authCredential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}

// MARK: - Sign In Anonymous
extension AuthenticationManager {
    @discardableResult
    func signInAnonymously() async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func linkApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        AnalyticsManager.shared.logEvent(name: "LinkAppleAccount")
        return try await linkCredential(credential: credential)
    }
    
    func linkGoogle(tokens: GoogleSignInResult) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        AnalyticsManager.shared.logEvent(name: "LinkGoogleAccount")
        return try await linkCredential(credential: credential)
    }
    
    private func linkCredential(credential: AuthCredential) async throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseError.linkCredential
        }
        
        let authDataResult = try await user.link(with: credential)
        
        let authDataResultModel = AuthDataResultModel(user: authDataResult.user)
        try await UserManager.shared.updateUserAfterLink(authDataResultModel: authDataResultModel)
        
        return authDataResultModel
    }
}
