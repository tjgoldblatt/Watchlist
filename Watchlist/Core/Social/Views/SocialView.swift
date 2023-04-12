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
            try await WatchlistManager.shared.createWatchlistForUser(userId: user.userId)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addMediaToWatchlist() {
        guard let user else { return }
        let media = Media(mediaType: .movie, id: 1, originalTitle: "Avengers", originalName: "Avengers", overview: nil, voteAverage: 12, voteCount: nil, posterPath: nil, backdropPath: nil, genreIDS: nil, popularity: nil, firstAirDate: nil, originCountry: nil, originalLanguage: nil, name: nil, adult: nil, releaseDate: nil, title: nil, video: nil, profilePath: nil, knownFor: nil)
        
        Task {
            try await WatchlistManager.shared.createNewMediaInWatchlist(userId: user.userId, media: media)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func toggleMediaWatched(mediaId: Int?, watched: Bool) {
        guard let user, let mediaId else { return }
        Task {
            try await WatchlistManager.shared.toggleMediaWatched(userId: user.userId, mediaId: mediaId, watched: watched)
        }
    }
}

struct SocialView: View {
    @State private var showSignInView: Bool = false
    @StateObject var vm = SocialViewModel()

    @FirestoreQuery(collectionPath: "watchlists") var userWatchlist: [DBMedia]
    
    var body: some View {
        ZStack {
            if !showSignInView {
                SettingsView(showSignInView: $showSignInView)
                    .onAppear {
                        Task {
                            try? await vm.loadCurrentUser()
//                            print(userWatchlist)
                            
//                            vm.addMediaToWatchlist()
                            
//                            vm.toggleMediaWatched(mediaId: 1234, watched: false)
                            
//                            print("Watchlist After: ")
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
            
//                $watchlist.predicates = [ .whereField("userId", isEqualTo: user.userId)]
            
        }
        
        .fullScreenCover(isPresented: $showSignInView) {
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
