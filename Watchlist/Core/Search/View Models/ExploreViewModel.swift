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
	
    private var cancellables = Set<AnyCancellable>()
	
    var homeVM: HomeViewModel
	
    init(homeVM: HomeViewModel) {
        self.homeVM = homeVM
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
                    return DBMedia(media: $0, mediaType: .movie, watched: self.homeVM.isMediaInWatchlist(media: $0), personalRating: nil)
                }
            }
            .store(in: &cancellables)
        
        TMDbService.getPopularTVShows()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { popularTVShows in
                self.popularTVShows = popularTVShows.compactMap { [weak self] media in
                    guard let self else { return nil }
                    return DBMedia(media: media, mediaType: .tv, watched: self.homeVM.isMediaInWatchlist(media: media), personalRating: nil)
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
                    return DBMedia(media: $0, mediaType: .movie, watched: self.homeVM.isMediaInWatchlist(media: $0), personalRating: nil)
                }
            }
            .store(in: &cancellables)
        
        TMDbService.getTrendingTVShows()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { trendingTVShows in
                self.trendingTVShows = trendingTVShows.compactMap { [weak self] in
                    guard let self else { return nil }
                    return DBMedia(media: $0, mediaType: .tv, watched: self.homeVM.isMediaInWatchlist(media: $0), personalRating: nil)
                }
            }
            .store(in: &cancellables)
    }
}
