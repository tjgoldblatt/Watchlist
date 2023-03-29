//
//  HomeViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Foundation
import SwiftUI
import Blackbird

class HomeViewModel: ObservableObject {
    /// Explore search text
    @Published var searchText: String = ""
    
    /// Explore page results
    @Published var results: [Media] = []
    
    /// Changes when genres have been loaded
    @Published var isGenresLoaded: Bool = false
    
    /// List of movie genre options
    @Published var movieGenreList: [Genre] = []
    
    /// List of TV genre options
    @Published var tvGenreList: [Genre] = []
    
    /// Current selected tab
    @Published var selectedTab: Tab = .movies
    
    /// Tracks when user is selecting elements to delete
    @Published var editMode: EditMode = .inactive
    
    var database: Blackbird.Database?
    
    var movieWatchlist: [Media] = []
    var tvWatchlist: [Media] = []
    
    /// To track filtering
    @Published var genresSelected: Set<Genre> = []
    @Published var ratingSelected: Int = 0
    @Published var watchSelected: String = "Any"
    
    init() {
        Task {
            try await fetchRequests()
        }
    }
    
    @MainActor
    func fetchRequests() async throws {
        try await withThrowingTaskGroup(of: Void.self, body: { group in
            group.addTask(operation: { try await self.getMovieGenreList() })
            group.addTask(operation: { try await self.getTVGenreList() })
            try await group.waitForAll()
            isGenresLoaded = true
        })
    }
    
    func getMediaWatchlists() {
        Task {
            guard let database else { return }
            let tvMediaModel = try await MediaModel.read(from: database, matching: \.$mediaType == MediaType.tv.rawValue, orderBy: .ascending(\.$title))
            for model in tvMediaModel {
                let tvShow = decodeData(with: model.media)
                if let tvShow {
                    tvWatchlist.append(tvShow)
                }
            }
            
            let movieMediaModel = try await MediaModel.read(from: database, matching: \.$mediaType == MediaType.movie.rawValue, orderBy: .ascending(\.$title))
            for model in movieMediaModel {
                let movie = decodeData(with: model.media)
                if let movie {
                    movieWatchlist.append(movie)
                }
            }
        }
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
    
    /// To figure out what genres we want to show as options depending on the tab
    func convertGenreIDToGenre(for tab: Tab) -> [Genre] {
        var foundGenres: [Genre] = []
        let allMediaGenres = movieGenreList + tvGenreList
        
        switch tab {
            case .movies:
                // return genres found within watchlist
                for movie in movieWatchlist {
                    if let genreIDs = movie.genreIDS {
                        for genreID in genreIDs {
                            if let genre = allMediaGenres.first(where: { $0.id == genreID }) {
                                foundGenres.append(genre)
                            }
                        }
                    }
                }
            case .tvShows:
                for tvShow in tvWatchlist {
                    if let genreIDs = tvShow.genreIDS {
                        for genreID in genreIDs {
                            if let genre = allMediaGenres.first(where: { $0.id == genreID }) {
                                foundGenres.append(genre)
                            }
                        }
                    }
                }
            case .explore:
                for result in results {
                    if let genreIDs = result.genreIDS {
                        for genreID in genreIDs {
                            if let genre = allMediaGenres.first(where: { $0.id == genreID }) {
                                foundGenres.append(genre)
                            }
                        }
                    }
                }
        }
        return Array(Set(foundGenres))
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
        DispatchQueue.main.async {
            self.movieGenreList = genres
        }
        
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
        
        DispatchQueue.main.async {
            self.tvGenreList = genres
        }
    }
    
    func encodeData(with media: Media) -> Data? {
        do {
            return try JSONEncoder().encode(media)
        } catch let error {
            print("[💣] Failed to encode. \(error)")
            return nil
        }
    }
    
    func decodeData(with data: Data) -> Media? {
        do {
            return try JSONDecoder().decode(Media.self, from: data)
        } catch let error {
            print("[💣] Failed to decode. \(error)")
            return nil
        }
    }
    
    func groupMedia(mediaModel: [MediaModel]) -> [MediaModel] {
        return mediaModel.sorted(by: { !$0.watched && $1.watched })
    }
}
