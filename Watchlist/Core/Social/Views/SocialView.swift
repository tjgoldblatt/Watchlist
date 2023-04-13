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
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func createWatchlistForUser() {
        guard let user else { return }
        
        Task {
            try await WatchlistManager.shared.createWatchlistForUser()
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}

struct SocialView: View {
    @State private var showSignInView: Bool = false
    @StateObject var vm = SocialViewModel()
    @EnvironmentObject var homeVM: HomeViewModel

    @FirestoreQuery(collectionPath: "watchlists") var userWatchlist: [DBMedia]
    
    var body: some View {
        ZStack {
            if !showSignInView {
                SettingsView(showSignInView: $showSignInView)
                    .onAppear {
                        Task {
                            try? await vm.loadCurrentUser()
                        }
                    }
            }
        }
        .onAppear {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
            if let user = vm.user {
                $userWatchlist.path = "watchlists/\(user.userId)/userWatchlist"
                print($userWatchlist.path)
            }
        }
        
        .fullScreenCover(isPresented: $showSignInView, onDismiss: {
            Task {
                try await homeVM.getWatchlists()
            }
        }) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView()
    }
}
