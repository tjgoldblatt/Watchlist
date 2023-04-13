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
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    @StateObject var authVM = AuthenticationViewModel()
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State var showReAuthView: Bool = false
    
    var body: some View {
        ZStack {
            Color.theme.background
            
            VStack(spacing: 10) {
                // Hide log out button if user is anon
                //            if viewModel.authUser?.isAnonymous == false {
                Button("Log Out") {
                    homeVM.selectedTab = .movies
                    Task {
                        do {
                            try viewModel.signOut()
                            homeVM.showSignInView = true
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
                
            }
            .sheet(isPresented: $showReAuthView, onDismiss: {
                Task {
                    do {
                        try await viewModel.delete()
                        homeVM.selectedTab = .movies
                        homeVM.showSignInView = true
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
                        SignInWithAppleView(showSignInView: $homeVM.showSignInView)
                            .frame(height: 55)
                    }
                }
                .onTapGesture {
                    homeVM.showSignInView = true
                }
            }
            .onAppear {
                viewModel.loadAuthProviders()
                viewModel.loadAuthUser()
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
            SettingsView()
                .environmentObject(SettingsViewModel())
    }
}
