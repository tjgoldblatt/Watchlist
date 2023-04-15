//
//  DeleteAccountView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/15/23.
//

import SwiftUI
import GoogleSignInSwift

struct DeleteAccountView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    @EnvironmentObject private var authVM: AuthenticationViewModel
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Please reauthenticate to delete your account")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.text)
                    .padding(.horizontal)
                
                if viewModel.authProviders.contains(.google) {
                    CustomButton(isGoogle: true)
                        .onTapGesture {
                            Task {
                                do {
                                    try await authVM.signInGoogle()
                                } catch {
                                    print(error)
                                }
                            }
                        }
                }
                if viewModel.authProviders.contains(.apple) {
                    SignInWithAppleView(showSignInView: $homeVM.showSignInView)
                        .padding(.horizontal)
                        .frame(maxWidth: 500)
                }
                Spacer()
            }
            .padding()
            .padding(.top, 60)
            .onTapGesture {
                homeVM.showSignInView = true
            }
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

struct DeleteAccountView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteAccountView()
            .environmentObject(dev.homeVM)
            .environmentObject(AuthenticationViewModel())
            .environmentObject(SettingsViewModel())
    }
}
