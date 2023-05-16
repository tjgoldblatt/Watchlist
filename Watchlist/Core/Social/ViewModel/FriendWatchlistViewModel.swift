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
            movieList = [
                try! DBMedia(
                    media: Media(
                        mediaType: .movie,
                        id: 5,
                        originalTitle: "Batman: The Long Halloween, Part Two",
                        originalName: nil,
                        overview: "As Gotham City\'s young vigilante, the Batman, struggles to pursue a brutal serial killer, district attorney Harvey Dent gets caught in a feud involving the criminal family of the Falcones.",
                        voteAverage: 7.532,
                        voteCount: 13,
                        posterPath: "/f46QMSo2wAVY1ywrNc9yZv0rkNy.jpg",
                        backdropPath: "/ymX3MnaxAO3jJ6EQnuNBRWJYiPC.jpg",
                        genreIDS: [18],
                        releaseDate: "2021-10-1",
                        title: "Batman: The Long Halloween, Part Two"),
                    watched: false,
                    personalRating: 7.0),
                try! DBMedia(
                    media: Media(
                        mediaType: .movie,
                        id: 5,
                        originalTitle: "Batman: The Long Halloween, Part Two",
                        originalName: nil,
                        overview: "As Gotham City\'s young vigilante, the Batman, struggles to pursue a brutal serial killer, district attorney Harvey Dent gets caught in a feud involving the criminal family of the Falcones.",
                        voteAverage: 7.532,
                        voteCount: 13,
                        posterPath: "/f46QMSo2wAVY1ywrNc9yZv0rkNy.jpg",
                        backdropPath: "/ymX3MnaxAO3jJ6EQnuNBRWJYiPC.jpg",
                        genreIDS: [18],
                        releaseDate: "2021-10-1",
                        title: "Batman: The Long Halloween, Part Two"),
                    watched: false,
                    personalRating: 7.0),
            ]

            tvList = [
                try! DBMedia(
                    media: Media(
                        mediaType: .tv,
                        id: 1,
                        originalTitle: nil,
                        originalName: "Batman: The Brave and the Bold",
                        overview: "The Caped Crusader is teamed up with Blue Beetle, Green Arrow, Aquaman and countless others in his quest to uphold justice.",
                        voteAverage: 7.532,
                        voteCount: 13,
                        posterPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                        backdropPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                        genreIDS: [13],
                        firstAirDate: "2021-10-1",
                        name: "Batman: The Brave and the Bold"),
                    watched: true,
                    personalRating: 2),

                try! DBMedia(
                    media: Media(
                        mediaType: .tv,
                        id: 1,
                        originalTitle: nil,
                        originalName: "Batman: The Brave and the Bold",
                        overview: "The Caped Crusader is teamed up with Blue Beetle, Green Arrow, Aquaman and countless others in his quest to uphold justice.",
                        voteAverage: 7.532,
                        voteCount: 13,
                        posterPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                        backdropPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                        genreIDS: [13],
                        firstAirDate: "2021-10-1",
                        name: "Batman: The Brave and the Bold"),
                    watched: true,
                    personalRating: 2),
            ]
        }
    }
}
