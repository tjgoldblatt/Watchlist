//
//  HomeViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Foundation
import SwiftUI

// TODO: Store watchlist items on device and maybe pass this in as an environment variable?

class HomeViewModel: ObservableObject {
    @Published var isGenresLoaded: Bool
    
    /// List of movie genre options
    @Published var movieGenreList: [Genre] = []
    
    /// List of TV genre options
    @Published var tvGenreList: [Genre] = []
    
    /// Current selected tab
    @Published var selectedTab: TabBarItem = .home
    
    /// Local device TV Watchlist
    @Published var tvWatchList: [Media] = []
    
    /// Local device Movie Watchlist
    @Published var movieWatchList: [Media] = []
    
    init() {
        self.isGenresLoaded = false
        for i in 0..<15 {
            self.tvWatchList.append(
                Media(mediaType: .tv,
                      id: i,
                      originalTitle: nil,
                      originalName: "Batman: The Brave and the Bold",
                      overview: "The Caped Crusader is teamed up with Blue Beetle, Green Arrow, Aquaman and countless others in his quest to uphold justice.",
                      voteAverage: 7.532,
                      voteCount: 13,
                      posterPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                      backdropPath: "/roAoQx0TTDMCg6nXoo8ClP2TSe8.jpg",
                      genreIDS: [99],
                      popularity: nil,
                      firstAirDate: nil,
                      originCountry: nil,
                      originalLanguage: nil,
                      name: nil,
                      adult: nil,
                      releaseDate: nil,
                      title: nil,
                      video: nil,
                      profilePath: nil,
                      knownFor: nil)
            )
        }
        
        for i in 0..<15 {
            self.movieWatchList.append(
                Media(mediaType: .movie,
                      id: i,
                      originalTitle: "Batman: The Long Halloween, Part Two",
                      originalName: nil,
                      overview: "As Gotham City\'s young vigilante, the Batman, struggles to pursue a brutal serial killer, district attorney Harvey Dent gets caught in a feud involving the criminal family of the Falcones.",
                      voteAverage: 7.532,
                      voteCount: 13,
                      posterPath: "/f46QMSo2wAVY1ywrNc9yZv0rkNy.jpg",
                      backdropPath: "/ymX3MnaxAO3jJ6EQnuNBRWJYiPC.jpg",
                      genreIDS: [18],
                      popularity: nil,
                      firstAirDate: nil,
                      originCountry: nil,
                      originalLanguage: nil,
                      name: nil,
                      adult: nil,
                      releaseDate: nil,
                      title: nil,
                      video: nil,
                      profilePath: nil,
                      knownFor: nil)
            )
        }
    }
    
    @MainActor
    func fetchGenres() async throws {
       try await withThrowingTaskGroup(of: Void.self, body: { group in
            group.addTask(operation: { try await self.getMovieGenreList() })
            group.addTask(operation: { try await self.getTVGenreList() })
            try await group.waitForAll()
            isGenresLoaded = true
        })
    }
    
    func getGenreNames(for type: MediaType, genreIDs: [Int]) -> [Genre] {
        var genreNames: [Genre] = []
        switch type {
            case .movie:
                if !movieGenreList.isEmpty {
                    genreNames = movieGenreList.filter({ return genreIDs.contains($0.id) })
                } else {
                    print("[🔥] Movie Genre List Empty")
                }
            case .tv:
                if !tvGenreList.isEmpty {
                    genreNames = tvGenreList.filter({ return genreIDs.contains($0.id) })
                } else {
                    print("[🔥] TV Genre List Empty")
                }
            case .person:
                break
        }
        return genreNames
    }
    
    func getMovieGenreList() async throws {
        let genres: [Genre] = try await withCheckedThrowingContinuation({ continuation in
            TMDbService.getMovieGenreList { result in
                switch result {
                    case .success(let genres):
                        continuation.resume(returning: genres)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                }
            }
        })
        self.movieGenreList = genres
    }
    
    func getTVGenreList() async throws {
        let genres: [Genre] = try await withCheckedThrowingContinuation({ continuation in
            TMDbService.getTVGenreList { result in
                switch result {
                    case .success(let genres):
                        continuation.resume(returning: genres)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                }
            }
        })
        self.tvGenreList = genres
    }
}
