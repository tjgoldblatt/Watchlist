//
//  SocialView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/11/23.
//

import SwiftUI
import FirebaseFirestoreSwift

@MainActor
final class SocialViewModel: ObservableObject {
    @Published var displayName: String? = nil
    
    func getDisplayName() {
        Task {
            displayName = try await UserManager.shared.getDisplayNameForUser()
        }
    }
}

struct SocialView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    
    @StateObject var settingsVM = SettingsViewModel()
    
    @State private var showSignInView: Bool = false
    @StateObject var vm = SocialViewModel()
    
    @State var showSettingsView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                if settingsVM.authUser?.isAnonymous == false {
                    // Show friends list
                    VStack {
                        Text(settingsVM.authUser?.uid ?? "")
                            .padding()
                        Text(vm.displayName ?? "No Display Name")
                            .padding()
                        HStack {
                            ForEach(settingsVM.authProviders, id: \.self) { auth in
                                Text(auth.rawValue)
                                    .padding()
                            }
                        }
                    }
                } else {
                    anonUser
                }
            }
            .onAppear {
                settingsVM.loadAuthProviders()
                settingsVM.loadAuthUser()
                vm.getDisplayName()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "gear")
                        .font(.headline)
                        .onTapGesture {
                            showSettingsView.toggle()
                        }
                }
            }
            .sheet(isPresented: $showSettingsView) {
                SettingsView()
                    .environmentObject(settingsVM)
            }
        }
    }
}

struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView()
            .environmentObject(dev.homeVM)
    }
}

extension SocialView {
    private var anonUser: some View {
        VStack {
            if !settingsVM.authProviders.contains(.google) {
                Button("Link Google Account") {
                    Task {
                        do {
                            try await settingsVM.linkGoogleAccount()
                            print("GOOGLE LINKED")
                        } catch(let error) {
                            print(error.localizedDescription)
                        }
                    }
                }
                .padding()
            }
            if !settingsVM.authProviders.contains(.apple) {
                Button("Sign in with Apple Account") {
                    Task {
                        do {
                            try await settingsVM.linkAppleAccount()
                            print("APPLE LINKED")
                        } catch(let error) {
                            print(error.localizedDescription)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
