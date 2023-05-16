//
//  MediaModalViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/4/23.
//

import Combine
import Foundation

@MainActor
final class MediaModalViewModel: ObservableObject {
    @Published var isAdded = false
    
    @Published var showingRating = false
    @Published var showDeleteConfirmation = false
    
    @Published var selectedOption: String = "Clear Rating"
    let options = ["Clear Rating"]
    
    @Published var media: DBMedia
    
    var cancellables = Set<AnyCancellable>()
    
    var countryProvider: Country?
    
    var imagePath: String {
        if let backdropPath = media.backdropPath {
            return backdropPath
        } else if let posterPath = media.posterPath {
            return posterPath
        } else {
            return ""
        }
    }
    
    init(media: DBMedia) {
        self.media = media
        getWatchProviders(mediaType: media.mediaType, for: media.id)
    }
    
    func updateMediaDetails() {
        TMDbService.getMediaDetails(mediaType: media.mediaType, for: media.id)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { [weak self] updatedMedia in
                guard let self else { return }
                let genreIds = media.genreIDs
                let updatedDBMedia = DBMedia(media: updatedMedia, watched: media.watched, personalRating: media.personalRating)
                
                media = updatedDBMedia
                media.genreIDs = genreIds
                
                Task {
                    try await WatchlistManager.shared.updateMediaInWatchlist(media: self.media)
                }
            }
            .store(in: &cancellables)
    }
    
    func getWatchProviders(mediaType: MediaType, for id: Int) {
        TMDbService.getWatchProviders(mediaType: mediaType, for: id)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { [weak self] results in
                guard let self else { return }
                
                let countryCode = NSLocale.current.language.region?.identifier ?? "US"
                guard let countryDictionary = results.dictionary[countryCode] else { return }
                
                self.countryProvider = try? Country(from: countryDictionary)
            }
            
            .store(in: &cancellables)
    }
}

extension MediaModalViewModel {
    convenience init(forPreview: Bool = false) {
        self.init(media:
            DBMedia(
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
                personalRating: 7.0))
        if ApplicationHelper.isDebug, forPreview {
            self.countryProvider = Country(
                link: "https://www.themoviedb.org/movie/109410-42/watch?locale=US",
                buy: [Provider(logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg", providerID: 8, providerName: "Netflix", displayPriority: 0)],
                rent: [Provider(logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg", providerID: 8, providerName: "Netflix", displayPriority: 0)],
                ads: [Provider(logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg", providerID: 8, providerName: "Netflix", displayPriority: 0)],
                flatrate: [Provider(logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg", providerID: 8, providerName: "Netflix", displayPriority: 0)],
                free: [Provider(logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg", providerID: 8, providerName: "Netflix", displayPriority: 0)])
        }
    }
}
