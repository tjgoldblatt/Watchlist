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
        if media.mediaType == .movie {
            TMDbService.getMovieDetails(for: media.id)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: NetworkingManager.handleCompletition) { [weak self] movieDetail in
                    guard let self,
                          let updatedDBMedia: DBMedia = movieDetail.convertToMedia(dbMedia: media) else { return }

                    media = updatedDBMedia

                    Task {
                        do {
                            try await WatchlistManager.shared.updateMediaInWatchlist(media: self.media)
                        } catch {
                            CrashlyticsManager.handleError(error: error)
                        }
                    }
                }
                .store(in: &cancellables)
        } else {
            TMDbService.getTVDetails(for: media.id)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: NetworkingManager.handleCompletition) { [weak self] tvDetail in
                    guard let self,
                          let updatedDBMedia: DBMedia = tvDetail.convertToMedia(dbMedia: media) else { return }

                    media = updatedDBMedia

                    Task {
                        try await WatchlistManager.shared.updateMediaInWatchlist(media: self.media)
                    }
                }
                .store(in: &cancellables)
        }
    }

    func getWatchProviders(mediaType: MediaType, for id: Int) {
        TMDbService.getWatchProviders(mediaType: mediaType, for: id)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { [weak self] results in
                guard let self else { return }

                let countryCode = NSLocale.current.language.region?.identifier ?? "US"
                guard let countryDictionary = results.dictionary[countryCode] else { return }

                countryProvider = try? Country(from: countryDictionary)
            }

            .store(in: &cancellables)
    }
}

extension MediaModalViewModel {
    convenience init(forPreview: Bool = false) {
        self.init(media: DBMedia.sampleMovie)

        if ApplicationHelper.isDebug, forPreview {
            countryProvider = Country(
                link: "https://www.themoviedb.org/movie/109410-42/watch?locale=US",
                buy: [Provider(
                    logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
                    providerID: 8,
                    providerName: "Netflix",
                    displayPriority: 0)],
                rent: [Provider(
                    logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
                    providerID: 8,
                    providerName: "Netflix",
                    displayPriority: 0)],
                ads: [Provider(
                    logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
                    providerID: 8,
                    providerName: "Netflix",
                    displayPriority: 0)],
                flatrate: [Provider(
                    logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
                    providerID: 8,
                    providerName: "Netflix",
                    displayPriority: 0)],
                free: [Provider(
                    logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
                    providerID: 8,
                    providerName: "Netflix",
                    displayPriority: 0)])
        }
    }
}
