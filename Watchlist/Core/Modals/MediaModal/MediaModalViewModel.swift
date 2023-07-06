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

    func addToMediaList(isFriendView: Bool, _ homeVM: HomeViewModel) {
        Task {
            var mediaToAdd = media
            if isFriendView {
                mediaToAdd.watched = false
                mediaToAdd.personalRating = nil
            }

            try await WatchlistManager.shared.createNewMediaInWatchlist(media: mediaToAdd)
            if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: media.id),
               !isFriendView
            {
                media = updatedMedia
            }

            if !isFriendView {
                AnalyticsManager.shared.logEvent(name: "MediaModalView_AddMedia")
            } else {
                AnalyticsManager.shared.logEvent(name: "FriendMediaModalView_AddMedia")
            }
        }
    }

    func resetMedia(_ homeVM: HomeViewModel) {
        Task {
            AnalyticsManager.shared.logEvent(name: "MediaModalView_ResetMedia")
            try await setPersonalRating(nil)
            try await setMediaWatched(false)
            if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: media.id) {
                media = updatedMedia
            }
        }
    }

    func updateMedia() {
        Task {
            try await setMediaWatched(media.watched)
            try await setPersonalRating(media.personalRating)
        }
    }

    func setMediaCurrentlyWatching(_ currentlyWatching: Bool) {
        Task {
            try await WatchlistManager.shared.setMediaCurrentlyWatching(media: media, currentlyWatching: currentlyWatching)
        }
    }

    func setMediaWatched(_ watched: Bool) async throws {
        try await WatchlistManager.shared.setMediaWatched(media: media, watched: watched)
    }

    func setPersonalRating(_ personalRating: Double?) async throws {
        try await WatchlistManager.shared.setPersonalRatingForMedia(
            media: media,
            personalRating: personalRating
        )
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
    convenience init(forPreview: Bool = false, media: DBMedia) {
        self.init(media: media)

        if ApplicationHelper.isDebug, forPreview {
            countryProvider = Country(
                link: "https://www.themoviedb.org/movie/109410-42/watch?locale=US",
                buy: [Provider(
                    logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
                    providerID: 8,
                    providerName: "Netflix",
                    displayPriority: 0
                )],
                rent: [Provider(
                    logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
                    providerID: 8,
                    providerName: "Netflix",
                    displayPriority: 0
                )],
                ads: [Provider(
                    logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
                    providerID: 8,
                    providerName: "Netflix",
                    displayPriority: 0
                )],
                flatrate: [Provider(
                    logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
                    providerID: 8,
                    providerName: "Netflix",
                    displayPriority: 0
                )],
                free: [Provider(
                    logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
                    providerID: 8,
                    providerName: "Netflix",
                    displayPriority: 0
                )]
            )
        }
    }
}
