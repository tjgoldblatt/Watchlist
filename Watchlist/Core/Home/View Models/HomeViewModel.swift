//
//  HomeViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine
import Blackbird

@MainActor
final class HomeViewModel: ObservableObject {
    /// Prompt the user to sign back in
    @Published var showSignInView: Bool = false
    
    /// Explore search text
    @Published var searchText: String = ""
    
    /// User Movie Watchlist
    @Published var movieList: [DBMedia] = []
    
    /// User TVShow Watchlist
    @Published var tvList: [DBMedia] = []
    
    private var userWatchlistListneer: ListenerRegistration? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isMediaLoaded: Bool = false
    
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
    
    @Published var editMode: EditMode = .inactive
    
    var hapticFeedback = UIImpactFeedbackGenerator(style: .soft)
    
    var database: Blackbird.Database?
    
    /// To track filtering
    @Published var genresSelected: Set<Genre> = []
    @Published var ratingSelected: Int = 0
    @Published var watchSelected: WatchOptions = WatchOptions.unwatched
    @Published var sortingSelected: SortingOptions = SortingOptions.alphabetical
    
    init() {
        Task {
            try await fetchGenreLists()
        }
    }
    
    /// Fetches the list of genres from the API
    @MainActor func fetchGenreLists() async throws {
        try await withThrowingTaskGroup(of: Void.self, body: { group in
            group.addTask(operation: { try await self.getMovieGenreList() })
            group.addTask(operation: { try await self.getTVGenreList() })
            try await group.waitForAll()
            isGenresLoaded = true
        })
    }
    
    func addListenerForMedia() throws {
        let (publisher, listener) = try WatchlistManager.shared.addListenerForGetMedia()
        self.userWatchlistListneer = listener
        publisher
            .sink { completion in
            
            } receiveValue: { [weak self] updatedMediaArray in
                var updatedMovieList: [DBMedia] = []
                var updatedTVList: [DBMedia] = []
                
                for media in updatedMediaArray {
                    if media.mediaType == .movie {
                        updatedMovieList.append(media)
                    } else if media.mediaType == .tv {
                        updatedTVList.append(media)
                    }
                }
                
                self?.movieList = updatedMovieList
                self?.tvList = updatedTVList
                
                self?.isMediaLoaded = true
            }
            .store(in: &cancellables)
    }
    
    func getUpdatedMediaFromList(mediaId: Int) -> DBMedia? {
        for media in tvList + movieList {
            if media.id == mediaId {
                return media
            }
        }
        return nil
    }
    
    // TODO: Blackbird Copy Func
    func transferDatabase() {
        Task {
            try await WatchlistManager.shared.createWatchlistForUser()
            let transferredFlag = try await WatchlistManager.shared.getTransferred()
            
            if transferredFlag == nil {
                let fbMediaList = movieList + tvList
                
                guard let database else { return }
                let mediaModels = try await MediaModel.read(from: database)
                
                for mediaModel in mediaModels {
                    if !fbMediaList.map({ $0.id }).contains(mediaModel.id) && mediaModel.id != 1 {
                        do {
                            try await WatchlistManager.shared.copyBlackbirdToFBForUser(mediaModel: mediaModel)
                        } catch {
                            print(error)
                        }
                    }
                }
                try await WatchlistManager.shared.setTransferred()
            }
        }
    }
    
    /// Get Genres for a specific MediaType
    func getGenresForMediaType(for type: MediaType, genreIDs: [Int]) -> [Genre] {
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
    func convertGenreIDToGenre(for tab: Tab, watchList: [DBMedia]) -> [Genre] {
        var foundGenres: [Genre] = []
        let allMediaGenres = movieGenreList + tvGenreList
        
        for media in watchList {
            if let genreIDs = media.genreIDs {
                for genreID in genreIDs {
                    if let genre = allMediaGenres.first(where: { $0.id == genreID }) {
                        foundGenres.append(genre)
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
}
