//
//  HomeViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

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

    /// To track filtering
    @Published var genresSelected: Set<Genre> = []
    @Published var ratingSelected: Int = 0
    @Published var selectedWatchOption: WatchOptions = .unwatched
    @Published var selectedSortingOption: SortingOptions = .personalRating

    /// Deep linking
    @Published var deepLinkURL: URL?

    /// Watchlist Listener
    private var userWatchlistListener: ListenerRegistration?

    /// Cancellables
    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchGenreLists()
    }

    func isMediaIDInWatchlist(for id: Int) -> Bool {
        for watchlistMedia in tvList + movieList where watchlistMedia.id == id {
            return true
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

                movieList = updatedMovieList
                tvList = updatedTVList

                isMediaLoaded = true
            }
            .store(in: &cancellables)
    }
}

// MARK: - Genre

extension HomeViewModel {
    /// Fetches the list of genres from the API
    @MainActor
    func fetchGenreLists() {
        getMovieGenreList()
        getTVGenreList()
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
    func convertGenreIDToGenre(for _: Tab, watchList: [DBMedia]) -> [Genre] {
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
            isMediaLoaded = true
            movieList = MockService.mockMovieList
            tvList = MockService.mockTVList
        }
    }
}
