//
//  HomeViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

//import Blackbird
import Combine
import FirebaseFirestore
import Foundation
import SwiftUI

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
    
    @Published var pendingFriendRequests = 0
    
    var hapticFeedback = UIImpactFeedbackGenerator(style: .soft)
    
//    // TODO: remove this
//    var database: Blackbird.Database?
    
    /// To track filtering
    @Published var genresSelected: Set<Genre> = []
    @Published var ratingSelected: Int = 0
    @Published var watchSelected: WatchOptions = .unwatched
    @Published var sortingSelected: SortingOptions = .alphabetical
    
    /// Watchlist Listener
    private var userWatchlistListener: ListenerRegistration? = nil
    
    /// Cancellables
    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchGenreLists()
    }
    
    func isDBMediaInWatchlist(dbMedia: DBMedia) -> Bool {
        for watchlistMedia in tvList + movieList {
            if watchlistMedia.id == dbMedia.id {
                return true
            }
        }
        return false
    }
    
    func isMediaInWatchlist(media: Media) -> Bool {
        for watchlistMedia in tvList + movieList {
            if watchlistMedia.id == media.id {
                return true
            }
        }
        return false
    }
    
    func getUpdatedMediaFromList(mediaId: Int) -> DBMedia? {
        if let media = (tvList + movieList).first(where: { $0.id == mediaId }) {
            return media
        } else {
            return nil
        }
    }
    
//    // TODO: Remove Blackbird Copy Func
//    func transferDatabase() async throws {
//        let transferredFlag = try? await WatchlistManager.shared.getTransferred()
//
//        if transferredFlag == nil {
//            let fbMediaList = movieList + tvList
//
//            guard let database else { return }
//            let mediaModels = try await MediaModel.read(from: database)
//            
//            for mediaModel in mediaModels {
//                if !fbMediaList.map({ $0.id }).contains(mediaModel.id) && mediaModel.id != 1 {
//                    do {
//                        try await WatchlistManager.shared.copyBlackbirdToFBForUser(mediaModel: mediaModel)
//                    } catch {
//                        CrashlyticsManager.handleError(error: error)
//                    }
//                }
//            }
//
//            try await WatchlistManager.shared.setTransferred()
//        }
//    }
}

// MARK: - Media Listener

extension HomeViewModel {
    func addListenerForMedia() throws {
        let (publisher, listener) = try WatchlistManager.shared.addListenerForGetMedia()
        userWatchlistListener = listener
        publisher
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { [weak self] updatedMediaArray in
                guard let self else { return }
                let updatedMovieList = updatedMediaArray.compactMap { $0.mediaType == .movie ? $0 : nil }
                let updatedTVList = updatedMediaArray.compactMap { $0.mediaType == .tv ? $0 : nil }
                
                self.movieList = updatedMovieList
                self.tvList = updatedTVList
                
                self.isMediaLoaded = true
            }
            .store(in: &cancellables)
    }
}

// MARK: - Genre

extension HomeViewModel {
    /// Fetches the list of genres from the API
    @MainActor
    func fetchGenreLists() {
        self.getMovieGenreList()
        self.getTVGenreList()
        isGenresLoaded = true
    }
    
    /// Get Genres for a specific MediaType
    func getGenresForMediaType(for type: MediaType, genreIDs: [Int]) -> [Genre] {
        var genreNames: [Genre] = []
        switch type {
            case .movie:
                if !movieGenreList.isEmpty {
                    genreNames = movieGenreList.filter { genreIDs.contains($0.id) }
                } else {
                    CrashlyticsManager.handleWarning(warning: "Movie Genre List Empty")
                }
            case .tv:
                if !tvGenreList.isEmpty {
                    genreNames = tvGenreList.filter { genreIDs.contains($0.id) }
                } else {
                    CrashlyticsManager.handleWarning(warning: "TV Genre List Empty")
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
    
    /// Fetches movie genre list from TMDBService
    func getMovieGenreList() {
        TMDbService.getMovieGenreList()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { genres in
                self.movieGenreList = genres
            }
            .store(in: &cancellables)
    }
    
    /// Fetches tv genre list from TMDBService
    func getTVGenreList() {
        TMDbService.getTVGenreList()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { genres in
                self.tvGenreList = genres
            }
            .store(in: &cancellables)
    }
}

// MARK: - Media Codable

extension HomeViewModel {
    func encodeData(with media: Media) -> Data? {
        do {
            return try JSONEncoder().encode(media)
        } catch {
            CrashlyticsManager.handleError(error: NetworkError.encode(error: error))
            return nil
        }
    }
    
    func decodeData(with data: Data) -> Media? {
        do {
            return try JSONDecoder().decode(Media.self, from: data)
        } catch {
            CrashlyticsManager.handleError(error: NetworkError.decode(error: error))
            return nil
        }
    }
}

extension HomeViewModel {
    convenience init(forPreview: Bool = false) {
        self.init()
        if ApplicationHelper.isDebug, forPreview {
            // Hard code your mock data for the preview here
            self.isMediaLoaded = true
            self.movieList = [
               try! DBMedia(
                    media: Media(mediaType: .movie,
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
                    watched: true,
                    personalRating: 7.0),
                try! DBMedia(
                    media: Media(mediaType: .movie,
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
                    media: Media(mediaType: .movie,
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
            
            self.tvList = [
                try! DBMedia(
                    media: Media(mediaType: .tv,
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
                    watched: false,
                    personalRating: 2),
                try! DBMedia(
                    media: Media(mediaType: .tv,
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
                    media: Media(mediaType: .tv,
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
                    watched: false,
                    personalRating: 2),
            ]
        }
    }
}
