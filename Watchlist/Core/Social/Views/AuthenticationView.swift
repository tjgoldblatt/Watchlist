//
//  AuthenticationView.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/6/23.
//

import SwiftUI
import GoogleSignInSwift
import AuthenticationServices

struct AuthenticationView: View {
    @EnvironmentObject private var viewModel: AuthenticationViewModel
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }

            SignInWithAppleView(showSignInView: $showSignInView)
                .frame(height: 55)
            
            Button {
                Task {
                    do {
                        try await viewModel.signInAnonymous()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Continue Without Signing In")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.red)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 55)
//                    .background(.orange)
//                    .cornerRadius(10)
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false))
                .environmentObject(AuthenticationViewModel())
        }
    }
}
