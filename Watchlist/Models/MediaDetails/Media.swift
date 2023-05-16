//
//  Media.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/11/23.
//

import Foundation

struct MediaResponse: Codable {
    let results: [Media]
}

// MARK: - Result

struct Media: Codable, Identifiable, Hashable {
    let mediaType: MediaType?
    let id: Int?
    let originalTitle: String?
    let originalName: String?
    let overview: String?
    let voteAverage: Double?
    let voteCount: Int?
    let posterPath: String?
    let backdropPath: String?
    let genreIDS: [Int]?

    let popularity: Double?
    let firstAirDate: String?

    let originCountry: [String]?
    let originalLanguage: String?

    let name: String?
    let adult: Bool?
    let releaseDate, title: String?
    let video: Bool?
    let profilePath: String?
    let knownFor: [Media]?

    init(
        mediaType: MediaType?,
        id: Int?,
        originalTitle: String? = nil,
        originalName: String? = nil,
        overview: String? = nil,
        voteAverage: Double? = nil,
        voteCount: Int? = nil,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        genreIDS: [Int]? = nil,
        popularity: Double? = nil,
        firstAirDate: String? = nil,
        originCountry: [String]? = nil,
        originalLanguage: String? = nil,
        name: String? = nil,
        adult: Bool? = nil,
        releaseDate: String? = nil,
        title: String? = nil,
        video: Bool? = nil,
        profilePath: String? = nil,
        knownFor: [Media]? = nil)
    {
        self.mediaType = mediaType
        self.id = id
        self.originalTitle = originalTitle
        self.originalName = originalName
        self.overview = overview
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.genreIDS = genreIDS
        self.popularity = popularity
        self.firstAirDate = firstAirDate
        self.originCountry = originCountry
        self.originalLanguage = originalLanguage
        self.name = name
        self.adult = adult
        self.releaseDate = releaseDate
        self.title = title
        self.video = video
        self.profilePath = profilePath
        self.knownFor = knownFor
    }

    enum CodingKeys: String, CodingKey {
        case posterPath = "poster_path"
        case popularity, id, overview
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case mediaType = "media_type"
        case firstAirDate = "first_air_date"
        case originCountry = "origin_country"
        case genreIDS = "genre_ids"
        case originalLanguage = "original_language"
        case voteCount = "vote_count"
        case name
        case originalName = "original_name"
        case adult
        case releaseDate = "release_date"
        case originalTitle = "original_title"
        case title, video
        case profilePath = "profile_path"
        case knownFor = "known_for"
    }
}

enum MediaType: String, Codable {
    case movie
    case tv
    case person
}
