//
//  SignInAppleHelper.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/7/23.
//

import AuthenticationServices
import CryptoKit
import Foundation
import SwiftUI

struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style

    func makeUIView(context _: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
    }

    func updateUIView(_: ASAuthorizationAppleIDButton, context _: Context) { }
}

@MainActor
final class SignInWithAppleHelper: NSObject {
    private var currentNonce: String?
    private var completitionHandler: ((Result<SignInWithAppleResult, Error>) -> Void)?

    func signIn() async throws -> SignInWithAppleResult {
        try await withCheckedThrowingContinuation { continuation in
            self.startSignInWithAppleFlow { result in
                switch result {
                    case let .success(signInAppleResult):
                        continuation.resume(returning: signInAppleResult)
                        return
                    case let .failure(failure):
                        continuation.resume(throwing: failure)
                        return
                }
            }
        }
    }

    func startSignInWithAppleFlow(completition: @escaping (Result<SignInWithAppleResult, Error>) -> Void) {
        let topVC = UIApplication.shared.rootController()
        let nonce = randomNonceString()
        currentNonce = nonce
        completitionHandler = completition
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = topVC
        authorizationController.performRequests()
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

    // Hashing function using CryptoKit
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

extension SignInWithAppleHelper: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else {
            completitionHandler?(.failure(FirebaseError.signInWithApple()))
            return
        }

        if let fullName = appleIDCredential.fullName {
            if let givenName = fullName.givenName, let familyName = fullName.familyName {
                Task {
                    try await UserManager.shared.updateDisplayNameForUser(displayName: "\(givenName) \(familyName)")
                }
            }
        }

        let tokens = SignInWithAppleResult(token: idTokenString, nonce: nonce)

        completitionHandler?(.success(tokens))
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        completitionHandler?(
            .failure(
                FirebaseError
                    .signInWithApple(debugDescription: error.localizedDescription.debugDescription)
            )
        )
    }
}

extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
