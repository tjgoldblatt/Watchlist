//
//  DBMedia.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/3/23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

struct DBMedia: Codable, Identifiable, Hashable {
    // Media
    let id: Int
    let mediaType: MediaType
    let title, originalTitle: String?
    let name, originalName: String?
    let overview: String?
    let voteAverage: Double?
    let voteCount: Int?
    let posterPath: String?
    let backdropPath: String?
    var genreIDs: [Int]?
    let releaseDate: String?
    let firstAirDate: String?

    // Extra
    var watched: Bool
    var personalRating: Double?

    init(media: Media, mediaType: MediaType? = nil, watched: Bool, personalRating: Double?) throws {
        guard let mediaId = media.id,
              let type = media.mediaType ?? mediaType else { throw TMDbError.failedToEncodeData }

        id = mediaId
        self.mediaType = type
        title = media.title
        originalTitle = media.originalTitle
        name = media.name
        originalName = media.originalName
        overview = media.overview
        voteAverage = media.voteAverage
        voteCount = media.voteCount
        posterPath = media.posterPath
        backdropPath = media.backdropPath
        genreIDs = media.genreIDS
        self.watched = watched
        self.personalRating = personalRating
        releaseDate = media.releaseDate
        firstAirDate = media.firstAirDate
    }

    enum CodingKeys: String, CodingKey {
        case id
        case mediaType
        case title
        case originalTitle
        case name
        case originalName
        case overview
        case voteAverage
        case voteCount
        case posterPath
        case backdropPath
        case genreIDs

        case watched
        case personalRating

        case releaseDate
        case firstAirDate
    }

    func convertDBMediaToMedia() -> Media {
        Media(
            mediaType: mediaType,
            id: id,
            originalTitle: originalTitle,
            originalName: originalName,
            overview: overview,
            voteAverage: voteAverage,
            voteCount: voteCount,
            posterPath: posterPath,
            backdropPath: backdropPath,
            genreIDS: genreIDs,
            popularity: nil,
            firstAirDate: firstAirDate,
            originCountry: nil,
            originalLanguage: nil,
            name: name,
            adult: nil,
            releaseDate: releaseDate,
            title: title,
            video: nil,
            profilePath: nil,
            knownFor: nil)
    }
}
