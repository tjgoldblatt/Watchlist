//
//  SearchTabViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Combine
import Foundation

@MainActor
final class ExploreViewModel: ObservableObject {
    @Published var isSearching = false

    @Published var popularMovies: [DBMedia] = []
    @Published var popularTVShows: [DBMedia] = []

    @Published var trendingMovies: [DBMedia] = []
    @Published var trendingTVShows: [DBMedia] = []

    @Published var topRatedMovies: [DBMedia] = []
    @Published var topRatedTVShows: [DBMedia] = []

    private var cancellables = Set<AnyCancellable>()

    var homeVM: HomeViewModel

    init(homeVM: HomeViewModel) {
        self.homeVM = homeVM
        loadMedia()
    }

    func loadMedia() {
        getTopRatedMedia()
        getPopularMedia()
        getTrendingMedia()
    }

    func search() {
        isSearching = true
        TMDbService.search(with: homeVM.searchText)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { mediaArray in
                self.homeVM.results = mediaArray
                self.isSearching = false
            }
            .store(in: &cancellables)
    }

    func getPopularMedia() {
        TMDbService.getPopularMovies()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { popularMovies in
                self.popularMovies = popularMovies.compactMap { [weak self] in
                    guard let self else { return nil }

                    return convertDBMedia(media: $0, mediaType: .movie)
                }
            }
            .store(in: &cancellables)

        TMDbService.getPopularTVShows()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { popularTVShows in
                self.popularTVShows = popularTVShows.compactMap { [weak self] in
                    guard let self else { return nil }

                    return convertDBMedia(media: $0, mediaType: .tv)
                }
            }
            .store(in: &cancellables)
    }

    func getTrendingMedia() {
        TMDbService.getTrendingMovies()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { trendingMovies in
                self.trendingMovies = trendingMovies.compactMap { [weak self] in
                    guard let self else { return nil }

                    return convertDBMedia(media: $0, mediaType: .movie)
                }
            }
            .store(in: &cancellables)

        TMDbService.getTrendingTVShows()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { trendingTVShows in
                self.trendingTVShows = trendingTVShows.compactMap { [weak self] in
                    guard let self else { return nil }

                    return convertDBMedia(media: $0, mediaType: .tv)
                }
            }
            .store(in: &cancellables)
    }

    func getTopRatedMedia() {
        TMDbService.getTopRatedMovies()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { topRatedMovies in
                self.topRatedMovies = topRatedMovies.compactMap { [weak self] in
                    guard let self else { return nil }

                    return convertDBMedia(media: $0, mediaType: .movie)
                }
            }
            .store(in: &cancellables)

        TMDbService.getTopRatedTVShows()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { topRatedTVShows in
                self.topRatedTVShows = topRatedTVShows.compactMap { [weak self] in
                    guard let self else { return nil }

                    return convertDBMedia(media: $0, mediaType: .tv)
                }
            }
            .store(in: &cancellables)
    }

    private func convertDBMedia(media: Media, mediaType: MediaType? = nil) -> DBMedia? {
        guard let id = media.id else { return nil }

        let allMedia = homeVM.tvList + homeVM.movieList

        if homeVM.isMediaIDInWatchlist(for: id) {
            return allMedia.first { $0.id == id }
        } else {
            return try? DBMedia(
                media: media,
                mediaType: mediaType,
                watched: false,
                personalRating: nil)
        }
    }
}
