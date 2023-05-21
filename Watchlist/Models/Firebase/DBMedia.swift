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

    static var sampleMovie: DBMedia {
        try! DBMedia(
            media: Media(
                mediaType: .movie,
                id: 736_074,
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
            personalRating: 7.0)
    }

    static var sampleTV: DBMedia {
        try! DBMedia(
            media: Media(
                mediaType: .tv,
                id: 15804,
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
            personalRating: 2)
    }
}
