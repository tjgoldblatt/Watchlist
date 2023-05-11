//
//  SettingsView.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/6/23.
//

import SwiftUI
import GoogleSignInSwift
import AuthenticationServices
import FirebaseAnalyticsSwift

struct SettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    @StateObject var authVM = AuthenticationViewModel()
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var csManager: ColorSchemeManager
    
    @State var showReAuthView: Bool = false
    @State var deleteAccountConfirmation: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                List {
                    appearanceSection
                        .listRowBackground(Color.theme.secondary)
                    accountSection
                        .listRowBackground(Color.theme.secondary)
//                    userInfoSection
                }
                .scrollContentBackground(.hidden)
                .onAppear {
                    viewModel.loadAuthProviders()
                    viewModel.loadAuthUser()
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .confirmationDialog("Are you sure you'd like to delete your account?", isPresented: $deleteAccountConfirmation, actions: {
                    Button("Delete", role: .destructive) {
                        AnalyticsManager.shared.logEvent(name: "SettingsView_DeleteAccount")
                        Task {
                            do {
                                viewModel.loadAuthUser()
                                try await viewModel.delete()
                                homeVM.selectedTab = .movies
                                homeVM.showSignInView = true
                            } catch {
                                CrashlyticsManager.handleError(error: error)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    Button("Cancel", role: .cancel) {}
                        .buttonStyle(.plain)
                })
                .fullScreenCover(isPresented: $showReAuthView, onDismiss: {
                    Task {
                        do {
                            viewModel.loadAuthUser()
                            try await viewModel.delete()
                            homeVM.selectedTab = .movies
                            homeVM.showSignInView = true
                        } catch {
                            CrashlyticsManager.handleError(error: error)
                        }
                    }
                }) {
                    DeleteAccountView()
                }
            }
        }
        .analyticsScreen(name: "SettingsView")
    }
}

extension SettingsView {
    private var appearanceSection: some View {
        Section {
            Picker("Theme", selection: $csManager.colorScheme) {
                Text("Light").tag(ColorScheme.light)
                Text("Dark").tag(ColorScheme.dark)
                Text("System").tag(ColorScheme.unspecified)
            }
        } header: {
            Text("Appearance")
        }
    }
    
    private var accountSection: some View {
        Section {
            if viewModel.authUser?.isAnonymous == false {
                Button("Log Out") {
                    AnalyticsManager.shared.logEvent(name: "SettingsView_LogOut")
                    homeVM.selectedTab = .movies
                    Task {
                        do {
                            try viewModel.signOut()
                            homeVM.selectedTab = .movies
                            homeVM.showSignInView = true
                        } catch {
                            CrashlyticsManager.handleError(error: error)
                        }
                    }
                }
                .foregroundColor(Color.theme.text)
            }
            
            
            Button(role: .destructive) {
                viewModel.loadAuthProviders()
                deleteAccountConfirmation.toggle()
            } label: {
                Text("Delete Account")
            }
        } header: {
            Text("Account")
        }
    }
    private var userInfoSection: some View {
        Section {
            if let currentUser = viewModel.authUser {
                Text(currentUser.uid)
                
                Text(currentUser.email ?? "No email associated")
            }
        } header: {
            Text("User Info")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsViewModel())
            .environmentObject(ColorSchemeManager())
    }
}
