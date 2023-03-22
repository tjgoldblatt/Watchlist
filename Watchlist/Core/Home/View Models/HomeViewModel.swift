//
//  HomeViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Foundation
import SwiftUI
import Blackbird

// TODO: Store watchlist items on device and maybe pass this in as an environment variable?

class HomeViewModel: ObservableObject {
    @Published var isGenresLoaded: Bool
    
    /// List of movie genre options
    @Published var movieGenreList: [Genre] = []
    
    /// List of TV genre options
    @Published var tvGenreList: [Genre] = []
    
    /// Current selected tab
    @Published var selectedTab: TabBarItem = .movie
    
    /// Local device TV Watchlist
    @Published var tvWatchList: [Media] = []
    
    /// Local device Movie Watchlist
    @Published var movieWatchList: [Media] = []
    
//    @Published var db: Blackbird.Database? = nil
    
    init() {
        self.isGenresLoaded = false
        
        Task {
            try await fetchRequests()
        }
    }
    
    @MainActor
    func fetchRequests() async throws {
        try await withThrowingTaskGroup(of: Void.self, body: { group in
            group.addTask(operation: { try await self.getMovieGenreList() })
            group.addTask(operation: { try await self.getTVGenreList() })
//            group.addTask(operation: { await self.getMoviesFromDatabase() })
//            group.addTask(operation: { await self.getTVFromDatabase() })
            try await group.waitForAll()
            isGenresLoaded = true
        })
    }
    
//    @MainActor
//    func reloadWatchlist() async {
//        await withTaskGroup(of: Void.self, body: { group in
//            group.addTask(operation: { await self.getMoviesFromDatabase() })
//            group.addTask(operation: { await self.getTVFromDatabase() })
//            await group.waitForAll()
//        })
//    }
    
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
    
    // MARK: - Blackbird
//    func addToDatabase(media: Media) async {
//        guard let id = media.id, let mediaType = media.mediaType, let data = encodeData(with: media) else { return }
//        do {
//            let post = Post(id: id, watched: false, mediaType: mediaType.rawValue, media: data)
//            try await post.write(to: db)
//        } catch let error {
//            print("[💣] Failed to write to Database. \(error)")
//        }
//    }
    
//    func markAsWatched(id: Int) async {
//        guard let db else { return }
//        
//        do {
//            try await Post.update(in: db, set: [\.$watched : true], matching: \.$id == id)
//        } catch let error {
//            print("[💣] Failed to mark \(id) as watched. \(error)")
//        }
//    }
    
//    func deleteMedia(id: Int) async {
//        guard let db else { return }
//
//        do {
//            let post = try await Post.read(from: db, id: id)
//            if let post {
//                if post.mediaType == "tv" {
//                    let filteredArray = self.tvWatchList.filter({ $0.id != post.id })
//                    self.tvWatchList = filteredArray
//                } else {
//                    let filteredArray = self.movieWatchList.filter({ $0.id != post.id })
//                    self.movieWatchList = filteredArray
//                }
//
//                let _ = Post.delete(post)
//            }
//        } catch let error {
//            print("[💣] Failed to delete \(id). \(error)")
//        }
//    }
    
//    func getFromDatabase(id: Int) async -> Media? {
//        guard let db else { return nil }
//        do {
//            let post = try await Post.read(from: db, id: id)
//            if let mediaData = post?.media, let media = decodeData(with: mediaData) {
//                return media
//            } else {
//                return nil
//            }
//        } catch let error {
//            print("[💣] Failed to read from Database. \(error)")
//            return nil
//        }
//    }
    
//    func getMoviesFromDatabase() async {
//        guard let db else { return }
//        do {
//            let posts = try await Post.read(from: db, matching: \.$mediaType == "movie")
//
//            for post in posts {
//                if let media = decodeData(with: post.media), let mediaType = media.mediaType {
//                    if !movieWatchList.contains(media) && mediaType.rawValue == "movie" {
//                        let mediaToAdd: Media = media
//                        print("🤔 \(media == mediaToAdd)")
//                        print("Added \(String(describing: media.title))")
//                        movieWatchList.append(mediaToAdd)
//                    }
//                }
//            }
//        } catch let error {
//            print("[💣] Failed to get Movies from Database. \(error)")
//        }
//    }
    
//    func getTVFromDatabase() async {
//        guard let db else { return }
//        do {
//            let posts = try await Post.read(from: db, matching: \.$mediaType == "tv")
//
//            for post in posts {
//                if let media = decodeData(with: post.media), let mediaType = media.mediaType {
//                    if !tvWatchList.contains(media) && mediaType.rawValue == "tv" {
//                        let mediaToAdd: Media = media
//                        print("🤔 \(media == mediaToAdd)")
//                        print("Added \(String(describing: media.name))")
//                        tvWatchList.append(mediaToAdd)
//
//                    }
//                }
//            }
//        } catch let error {
//            print("[💣] Failed to get Movies from Database. \(error)")
//        }
//    }
}
