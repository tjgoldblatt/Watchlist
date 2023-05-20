//
//  FriendWatchlistViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/7/23.
//
import SwiftUI

@MainActor
final class FriendWatchlistViewModel: ObservableObject {
    @Published var filterText: String = ""
    @Published var editMode: EditMode = .inactive

    @Published var user: DBUser?
    @Published var movieList: [DBMedia] = []
    @Published var tvList: [DBMedia] = []

    init(userId: String) {
        Task { @MainActor in
            self.user = try await UserManager.shared.getUser(userId: userId)
            getMedia()
        }
    }

    func getMedia() {
        guard let user else { return }
        Task {
            self.movieList = try await WatchlistManager.shared.getMedia(mediaType: .movie, forUser: user.userId)
            self.tvList = try await WatchlistManager.shared.getMedia(mediaType: .tv, forUser: user.userId)
        }
    }

    convenience init(forPreview: Bool = false) {
        self.init(userId: "abcd")
        if ApplicationHelper.isDebug, forPreview {
            movieList = [DBMedia.sampleMovie, DBMedia.sampleMovie, DBMedia.sampleMovie, DBMedia.sampleMovie]
            tvList = [DBMedia.sampleTV, DBMedia.sampleTV, DBMedia.sampleTV, DBMedia.sampleTV]
        }
    }
}
