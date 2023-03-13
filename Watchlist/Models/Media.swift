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
    case movie = "movie"
    case tv = "tv"
    case person = "person"
}
