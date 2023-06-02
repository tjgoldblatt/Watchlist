//
//  SignInWithAppleButton.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/7/23.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth
import SwiftUI

struct SignInWithAppleView: View {
    @Environment(\.colorScheme) var currentScheme
    @Binding var showSignInView: Bool

    var body: some View {
        if currentScheme == .light {
            SignInWithAppleButtonSwiftUI(showSignInView: $showSignInView)
                .signInWithAppleButtonStyle(.black)
        } else {
            SignInWithAppleButtonSwiftUI(showSignInView: $showSignInView)
                .signInWithAppleButtonStyle(.white)
        }
    }
}

struct SignInWithAppleButtonSwiftUI: View {
    @State var currentNonce: String?
    @Binding var showSignInView: Bool

    // Hashing function using CryptoKit
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    var body: some View {
        SignInWithAppleButton(
            .continue,
            onRequest: { request in
                let nonce = randomNonceString()
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = sha256(nonce)
            },

            onCompletion: { result in
                switch result {
                    case let .success(authResults):
                        switch authResults.credential {
                            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                guard let nonce = currentNonce else {
                                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                }
                                guard let appleIDToken = appleIDCredential.identityToken else {
                                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                }
                                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                    CrashlyticsManager
                                        .handleError(
                                            error: FirebaseError
                                                .signInWithApple(debugDescription: appleIDToken.debugDescription)
                                        )
                                    return
                                }

                                let tokens = SignInWithAppleResult(token: idTokenString, nonce: nonce)

                                Task {
                                    let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
                                    let user = DBUser(auth: authDataResult)
                                    try await UserManager.shared.createNewUser(user: user)
                                    if let fullName = appleIDCredential.fullName {
                                        if let givenName = fullName.givenName, let familyName = fullName.familyName {
                                            try await UserManager.shared
                                                .updateDisplayNameForUser(displayName: "\(givenName) \(familyName)")
                                        }
                                    }
                                    showSignInView = false
                                }

                            default:
                                break
                        }
                    default:
                        break
                }
            }
        )
        .frame(height: 55, alignment: .center)
        .clipShape(Capsule())
    }

    struct SignInWithAppleButtonSwiftUI_Previews: PreviewProvider {
        static var previews: some View {
            SignInWithAppleView(showSignInView: .constant(false))
        }
    }
}

struct SignInWithAppleResult {
    let token: String
    let nonce: String
}
