//
//  MovieDetails.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/15/23.
//

import Foundation

struct MovieDetails: Codable, MediaDetails {
    let adult: Bool?
    let backdropPath: String?
    let belongsToCollection: MovieCollection?
    let budget: Int?
    let genres: [Genre]?
    let homepage: String?
    let id: Int?
    let imdbID, originalLanguage, originalTitle, overview: String?
    let popularity: Double?
    let posterPath: String?
    let firstAirDate: String?
    let productionCompanies: [ProductionCompany]?
    let productionCountries: [ProductionCountry]?
    let releaseDate: String?
    let revenue, runtime: Int?
    let spokenLanguages: [SpokenLanguage]?
    let status, tagline, title: String?
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case belongsToCollection = "belongs_to_collection"
        case budget, genres, homepage, id
        case firstAirDate = "first_air_date"
        case imdbID = "imdb_id"
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case productionCompanies = "production_companies"
        case productionCountries = "production_countries"
        case releaseDate = "release_date"
        case revenue, runtime
        case spokenLanguages = "spoken_languages"
        case status, tagline, title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }

    func convertToMedia(dbMedia: DBMedia? = nil) -> DBMedia? {
        let media = Media(
            mediaType: .movie,
            id: id,
            originalTitle: originalTitle,
            overview: overview,
            voteAverage: voteAverage,
            voteCount: voteCount,
            posterPath: posterPath,
            backdropPath: backdropPath,
            genreIDS: genres?.map(\.id),
            popularity: popularity,
            firstAirDate: firstAirDate,
            originalLanguage: originalLanguage,
            adult: adult,
            releaseDate: releaseDate,
            title: title,
            video: video
        )

        do {
            return try DBMedia(
                media: media,
                currentlyWatching: dbMedia?.currentlyWatching ?? false,
                watched: dbMedia?.watched ?? false,
                personalRating: dbMedia?.personalRating ?? nil
            )
        } catch {
            CrashlyticsManager.handleError(error: NetworkError.encode(error: error))
            return nil
        }
    }
}

// MARK: - Movie Collection

struct MovieCollection: Codable {
    let id: Int
    let name: String?
    let posterPath: String?
    let backdropPath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
    }
}

// MARK: - ProductionCompany

struct ProductionCompany: Codable {
    let id: Int?
    let logoPath: String?
    let name, originCountry: String?

    enum CodingKeys: String, CodingKey {
        case id
        case logoPath = "logo_path"
        case name
        case originCountry = "origin_country"
    }
}
