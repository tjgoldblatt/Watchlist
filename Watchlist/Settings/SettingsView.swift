//
//  SettingsView.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/6/23.
//

import SwiftUI
import GoogleSignInSwift
import AuthenticationServices

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject var authVM = AuthenticationViewModel()
    @Binding var showSignInView: Bool
    @State var showReAuthView: Bool = false
    
    var body: some View {
        List {
            // Hide log out button if user is anon
//            if viewModel.authUser?.isAnonymous == false {
                Button("Log Out") {
                    Task {
                        do {
                            try viewModel.signOut()
                            showSignInView = true
                        } catch(let error) {
                            print(error.localizedDescription)
                        }
                    }
//                }
            }
            
            Button(role: .destructive) {
                viewModel.loadAuthProviders()
                showReAuthView.toggle()
            } label: {
                Text("Delete Account")
            }

//
//            if viewModel.authProviders.contains(.email) {
//                emailSection
//            }
            
//            if viewModel.authUser?.isAnonymous == true {
                anonymousSection
//            }

        }
        .sheet(isPresented: $showReAuthView, onDismiss: {
            Task {
                do {
                    // show alert to confirm, need to implement if we want to create accounts
                    try await viewModel.delete()
                    showSignInView = true
                } catch(let error) {
                    print(error.localizedDescription)
                }
            }
        }) {
            VStack {
                if viewModel.authProviders.contains(.google) {
                    GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
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
                    SignInWithAppleView(showSignInView: $showSignInView)
                        .frame(height: 55)
                }
            }
        }
        .onAppear {
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(showSignInView: .constant(false))
                .environmentObject(AuthenticationViewModel())
        }
    }
}

extension SettingsView {
//    private var emailSection: some View {
//        Section {
//            Button("Reset Password") {
//                Task {
//                    do {
//                        try await viewModel.resetPassword()
//                        print("PASSWORD RESET")
//                    } catch(let error) {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//
//            Button("Update Password") {
//                Task {
//                    do {
//                        try await viewModel.updatePassword()
//                        print("PASSWORD UPDATED")
//                    } catch(let error) {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//
//            Button("Update Email") {
//                Task {
//                    do {
//                        try await viewModel.updateEmail()
//                        print("EMAIL UPDATED")
//                    } catch(let error) {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
//        } header: {
//            Text("Email functions")
//        }
//    }
    
    // These would normally just be shown as the regular sign in buttons
    private var anonymousSection: some View {
        Section {
            Button("Link Google Account") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("GOOGLE LINKED")
                    } catch(let error) {
                        print(error.localizedDescription)
                    }
                }
            }
            
            Button("Link Apple Account") {
                Task {
                    do {
                        try await viewModel.linkAppleAccount()
                        print("APPLE LINKED")
                    } catch(let error) {
                        print(error.localizedDescription)
                    }
                }
            }
            
//            Button("Link Email Account") {
//                Task {
//                    do {
//                        try await viewModel.linkEmailAccount()
//                        print("EMAIL LINKED")
//                    } catch(let error) {
//                        print(error.localizedDescription)
//                    }
//                }
//            }
        } header: {
            Text("Create account")
        }
    }
}
