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
    var currentlyWatching: Bool
    var bookmarked: Bool
    var watched: Bool
    var personalRating: Double?
    @ServerTimestamp var lastUpdated: Timestamp?

    init(
        media: Media,
        mediaType: MediaType? = nil,
        currentlyWatching: Bool,
        bookmarked: Bool,
        watched: Bool,
        personalRating: Double?
    )
        throws
    {
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
        self.currentlyWatching = currentlyWatching
        self.bookmarked = bookmarked
        self.watched = watched
        self.personalRating = personalRating
        lastUpdated = Timestamp(date: Date())
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

        case currentlyWatching
        case bookmarked
        case watched
        case personalRating
        case lastUpdated

        case releaseDate
        case firstAirDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        mediaType = try container.decode(MediaType.self, forKey: .mediaType)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        originalTitle = try container.decodeIfPresent(String.self, forKey: .originalTitle)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        originalName = try container.decodeIfPresent(String.self, forKey: .originalName)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage)
        voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        genreIDs = try container.decodeIfPresent([Int].self, forKey: .genreIDs)
        currentlyWatching = try container.decodeIfPresent(Bool.self, forKey: .currentlyWatching) ?? false
        bookmarked = try container.decodeIfPresent(Bool.self, forKey: .bookmarked) ?? false
        lastUpdated = try container.decodeIfPresent(Timestamp.self, forKey: .lastUpdated)
        watched = try container.decode(Bool.self, forKey: .watched)
        personalRating = try container.decodeIfPresent(Double.self, forKey: .personalRating)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        firstAirDate = try container.decodeIfPresent(String.self, forKey: .firstAirDate)
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
            knownFor: nil
        )
    }
}
