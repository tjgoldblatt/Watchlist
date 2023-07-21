//
//  SettingsView.swift
//  FirebaseBootcamp
//
//  Created by TJ Goldblatt on 4/6/23.
//

import AuthenticationServices
import FirebaseAnalyticsSwift
import GoogleSignInSwift
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: SettingsViewModel

    @StateObject var authVM = AuthenticationViewModel()
    @EnvironmentObject var homeVM: HomeViewModel
    @EnvironmentObject var csManager: ColorSchemeManager

    @State private var showReAuthView: Bool = false
    @State private var deleteAccountConfirmation: Bool = false

    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    @State private var showUpdateDisplayName = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()

                List {
                    //                    appearanceSection
                    //                        .listRowBackground(Color.gray.opacity(0.1))
                    if viewModel.currentUser != nil {
                        userInfoSection
                            .listRowBackground(Color.gray.opacity(0.1))
                    }
                    accountSection
                        .listRowBackground(Color.gray.opacity(0.1))
                    aboutSection
                        .listRowBackground(Color.gray.opacity(0.1))
                }
                .scrollContentBackground(.hidden)
                .onAppear {
                    viewModel.loadAuthProviders()
                    viewModel.loadAuthUser()
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .confirmationDialog(
                    "Are you sure you'd like to delete your account?",
                    isPresented: $deleteAccountConfirmation,
                    actions: {
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
                        Button("Cancel", role: .cancel) { }
                            .buttonStyle(.plain)
                    }
                )
                .fullScreenCover(isPresented: $showReAuthView) {
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
                } content: {
                    DeleteAccountView()
                }
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                if let url =
                    URL(
                        string: "https://docs.google.com/document/d/1gTVQkP6vcWYhKv4be5wW8m94FVD7vNCHuVIVc4LQ7wk/edit?usp=sharing"
                    )
                {
                    SFSafariViewWrapper(url: url).ignoresSafeArea(edges: .bottom)
                }
            }
            .sheet(isPresented: $showTermsOfService) {
                if let url =
                    URL(
                        string: "https://docs.google.com/document/d/19Exq6_JCh7QipaZVNRPbEBvrVaBAQDjM3lbEZ-tOQKo/edit?usp=sharing"
                    )
                {
                    SFSafariViewWrapper(url: url).ignoresSafeArea(edges: .bottom)
                }
            }
            .sheet(isPresented: $showUpdateDisplayName) {
                viewModel.loadAuthUser()
            } content: {
                DisplayNameView()
            }
        }
        .analyticsScreen(name: "SettingsView")
    }
}

extension SettingsView {
    // MARK: - Appearance

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

    // MARK: - Account

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

    // MARK: - User Info

    @ViewBuilder
    private var userInfoSection: some View {
        Section {
            if let currentUser = viewModel.currentUser {
                Button { showUpdateDisplayName = true } label: {
                    Text(currentUser.displayName ?? "No display name associated")
                }
                .foregroundColor(Color.theme.text)

                Text(currentUser.email ?? "No email associated")
            }
        } header: {
            Text("User Info")
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            Button("Terms of Service") {
                AnalyticsManager.shared.logEvent(name: "SettingsView_TermsOfService")
                showTermsOfService.toggle()
            }
            .foregroundColor(Color.theme.text)

            Button("Privacy Policy") {
                AnalyticsManager.shared.logEvent(name: "SettingsView_PrivacyPolicy")
                showPrivacyPolicy.toggle()
            }
            .foregroundColor(Color.theme.text)

            if let releaseVersion = Bundle.main.releaseVersionNumber,
               let buildVersion = Bundle.main.buildVersionNumber
            {
                Text("Version \(releaseVersion) (\(buildVersion))")
            }
        } header: {
            Text("About")
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
