//
//  SocialTabView.swift
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

struct SocialTabView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    
    @StateObject var settingsVM = SettingsViewModel()
    
    @State private var showSignInView: Bool = false
    @StateObject var vm = SocialViewModel()
    
    @State var showSettingsView: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                VStack(alignment: .center) {
                    VStack(alignment: .center) {
                        Text("Tab Under")
                        Text("Development")
                        Text("😸")
                    }
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.text)
                    
                    if settingsVM.authUser?.isAnonymous == false {
                        // Show friends list
                        Text(settingsVM.authUser?.uid ?? "")
                            .padding()
                        Text(vm.displayName ?? "No Display Name")
                            .padding()
                        Text(settingsVM.authUser?.email ?? "")
                            .padding()
                        HStack {
                            ForEach(settingsVM.authProviders, id: \.self) { auth in
                                Text(auth.rawValue)
                                    .padding()
                            }
                        }
                    }
                    
                    linkButtons
                    
                    Spacer()
                }
                .padding(.top)
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
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
        .analyticsScreen(name: "SocialTabView")
    }
}

struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialTabView()
            .environmentObject(dev.homeVM)
    }
}

extension SocialTabView {
    private var linkButtons: some View {
        VStack {
            if !settingsVM.authProviders.contains(.google) {
                Button("Sign in with Google") {
                    Task {
                        do {
                            try await settingsVM.linkGoogleAccount()
                        } catch {
                            CrashlyticsManager.handleError(error: error)
                        }
                    }
                }
                .padding()
            }
            if !settingsVM.authProviders.contains(.apple) {
                Button("Sign in with Apple") {
                    Task {
                        do {
                            try await settingsVM.linkAppleAccount()
                        } catch {
                            CrashlyticsManager.handleError(error: error)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
