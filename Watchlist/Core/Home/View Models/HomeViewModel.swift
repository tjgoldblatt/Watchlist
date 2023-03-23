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
    
    @Published var results: [Media] = []
    
    /// List of movie genre options
    @Published var movieGenreList: [Genre] = []
    
    /// List of TV genre options
    @Published var tvGenreList: [Genre] = []
    
    /// Current selected tab
    @Published var selectedTab: TabBarItem = .movie
    
    @Published var editMode: EditMode = .inactive
    
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
