//
//  SignInWithGoogleHelper.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/7/23.
//
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResult {
    let idToken: String
    let accessToken: String
}

final class SignInWithGoogleHelper {
    
    @MainActor
    func signIn() async throws -> GoogleSignInResult {
        let topViewController = UIApplication.shared.rootController()
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topViewController)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        return GoogleSignInResult(idToken: idToken, accessToken: accessToken)
    }
}

extension UIApplication {
    func rootController() -> UIViewController {
        guard let window = connectedScenes.first as? UIWindowScene else { return .init() }
        guard let viewController = window.windows.last?.rootViewController else { return .init() }
        
        return viewController
    }
}
