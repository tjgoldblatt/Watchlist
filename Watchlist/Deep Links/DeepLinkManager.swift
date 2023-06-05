//
//  DeepLinkManager.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/18/23.
//

import Foundation

enum DeepLinkURLs: String {
    case explore
    case social
}

@MainActor
enum DeepLinkManager {
    static func parse(
        from url: URL,
        homeVM: HomeViewModel
    )
    async -> DBMedia? {
        guard let host = url.host() else { return nil }

        switch DeepLinkURLs(rawValue: host) {
            case .explore:
                guard let queryParams = url.queryParameters else { return nil }

                let media = convertQueryParamsToMedia(queryParams: queryParams)
                var dbMedia = try? DBMedia(media: media, currentlyWatching: false, watched: false, personalRating: nil)

                if let id = media.id {
                    if homeVM.isMediaIDInWatchlist(for: id) {
                        dbMedia = (homeVM.movieList + homeVM.tvList).first { $0.id == id }
                    }
                }

                return dbMedia
            default:
                return nil
        }
    }

    static func build(from dbMedia: DBMedia) -> URL? {
        let media = dbMedia.convertDBMediaToMedia()

        let queryMediaType = media.mediaType?.rawValue
        let queryMediaID = media.id
        let queryOriginalTitle = media.originalTitle?.replacingOccurrences(of: " ", with: "+")
        let queryOriginalName = media.originalName?.replacingOccurrences(of: " ", with: "+")
        let queryOverview = media.overview?.replacingOccurrences(of: " ", with: "+")
        let queryVoteAverage = media.voteAverage
        let queryVoteCount = media.voteCount
        let queryPosterPath = media.posterPath
        let queryBackdropPath = media.backdropPath
        let queryGenreIDS = media.genreIDS
        let queryFirstAirDate = media.firstAirDate
        let queryMediaName = media.name?.replacingOccurrences(of: " ", with: "+")
        let queryReleaseDate = media.releaseDate
        let queryMediaTitle = media.title?.replacingOccurrences(of: " ", with: "+")

        var url = URL(string: "watchlist://explore")!
        var queryItems = [
            URLQueryItem(name: "mediaType", value: queryMediaType),
            URLQueryItem(name: "id", value: queryMediaID?.description),
            URLQueryItem(name: "originalTitle", value: queryOriginalTitle),
            URLQueryItem(name: "originalName", value: queryOriginalName),
            URLQueryItem(name: "overview", value: queryOverview),
            URLQueryItem(name: "posterPath", value: queryPosterPath),
            URLQueryItem(name: "backdropPath", value: queryBackdropPath),
            URLQueryItem(name: "firstAirDate", value: queryFirstAirDate),
            URLQueryItem(name: "name", value: queryMediaName),
            URLQueryItem(name: "releaseDate", value: queryReleaseDate),
            URLQueryItem(name: "title", value: queryMediaTitle),
            URLQueryItem(name: "foo", value: nil),
        ]

        if let queryVoteAverage {
            queryItems.append(URLQueryItem(name: "voteAverage", value: String(queryVoteAverage)))
        }

        if let queryVoteCount {
            queryItems.append(URLQueryItem(name: "voteCount", value: String(queryVoteCount)))
        }

        if let queryGenreIDS {
            queryItems.append(URLQueryItem(name: "genreIDS", value: queryGenreIDS.map(\.description).joined(separator: ",")))
        }

        url.append(queryItems: queryItems)

        return url
    }
}

extension DeepLinkManager {
    static func convertQueryParamsToMedia(queryParams: [String: String]) -> Media {
        Media(
            mediaType: MediaType(rawValue: queryParams["mediaType"] ?? ""),
            id: Int(queryParams["id"] ?? "0"),
            originalTitle: queryParams["originalTitle"],
            originalName: queryParams["originalName"],
            overview: queryParams["overview"],
            voteAverage: Double(queryParams["voteAverage"] ?? ""),
            voteCount: Int(queryParams["voteCount"] ?? ""),
            posterPath: queryParams["posterPath"],
            backdropPath: queryParams["backdropPath"],
            genreIDS: queryParams["genreIDS"]?.split(separator: ",").map { Int($0) ?? 0 },
            firstAirDate: queryParams["firstAirDate"],
            name: queryParams["name"],
            releaseDate: queryParams["releaseDate"],
            title: queryParams["title"]
        )
    }
}

extension URL {
    public var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { result, item in
            result[item.name] = item.value?.replacingOccurrences(of: "+", with: " ")
        }
    }
}
