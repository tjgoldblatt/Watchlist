//
//  AuthenticationView.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/6/23.
//

import SwiftUI
import GoogleSignInSwift
import AuthenticationServices
import FirebaseAnalytics
import FirebaseAnalyticsSwift

struct SignInView: View {
    @EnvironmentObject private var viewModel: AuthenticationViewModel
    @Binding var showSignInView: Bool
    @Environment(\.colorScheme) var currentScheme
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            VStack {
                VStack(alignment: .center, spacing: 15) {
                    Image(systemName: "popcorn.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .foregroundColor(Color.theme.red)
                    
                    Text("Welcome to Watchlist")
                        .foregroundColor(Color.theme.text)
                        .font(.title)
                        .fontWeight(.semibold)
                        .lineSpacing(10)
                        .padding(.top)
                    
                }
                .padding(.top, 50)
                .padding(.bottom)
                
                
                VStack(spacing: 20) {
                    // MARK: - Custom Apple Sign In Button
                    SignInWithAppleView(showSignInView: $showSignInView)
                        .padding(.horizontal)
                        .frame(maxWidth: 500)
                    
                    // MARK: - Custom Google button
                    CustomButton(isGoogle: true)
                        .onTapGesture {
                            Task {
                                do {
                                    try await viewModel.signInGoogle()
                                    showSignInView = false
                                } catch {
                                    CrashlyticsManager.handleError(error: error)
                                }
                            }
                        }
                }
                
                Button {
                    Task {
                        do {
                            try await viewModel.signInAnonymous()
                            showSignInView = false
                        } catch {
                            CrashlyticsManager.handleError(error: error)
                        }
                    }
                } label: {
                    Text("Continue Without Signing In")
                        .font(.subheadline)
                        .foregroundColor(Color.theme.red)
                }
                .padding(.top)
            }
            .padding(.bottom, 50)
        }
        .analyticsScreen(name: "SignInView")
        .onDisappear {
            AnalyticsManager.shared.logEvent(name: AnalyticsEventLogin)
        }
    }
    
    @ViewBuilder
    func CustomButton(isGoogle: Bool = false) -> some View {
        HStack(spacing: 3) {
            Group {
                if isGoogle {
                    Image("google")
                        .resizable()
                        .renderingMode(.template)
                } else {
                    Image(systemName: "applelogo")
                        .resizable()
                }
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 17, height: 17)
            .frame(height: 45)
            .foregroundColor(.white)
            
            Text("Continue with \(isGoogle ? "Google" : "Apple")")
                .font(.system(size: 21))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(1)
         }
        .frame(maxWidth: .infinity)
        .frame(height: 55)
        .background(.blue)
        .clipShape(Capsule())
        .padding(.horizontal)
        .frame(maxWidth: 500)
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView(showSignInView: .constant(false))
            .environmentObject(AuthenticationViewModel())
    }
}
