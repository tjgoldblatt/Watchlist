//
//  TraktResponse.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 7/6/23.
//

import Foundation

struct TraktMovie: Codable {
    let listCount: Int?
    let movie: MediaInfo?

    enum CodingKeys: String, CodingKey {
        case listCount = "list_count"
        case movie
    }
}

struct TraktTV: Codable {
    let listCount: Int?
    let show: MediaInfo?

    enum CodingKeys: String, CodingKey {
        case listCount = "list_count"
        case show
    }
}

// MARK: - MediaInfo

struct MediaInfo: Codable {
    let title: String?
    let year: Int?
    let ids: TraktResponseID?
}

// MARK: - TraktResponseID

struct TraktResponseID: Codable {
    let trakt: Int?
    let slug, imdb: String?
    let tmdb: Int?
}
