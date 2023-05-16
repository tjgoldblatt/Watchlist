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
        
        self.id = mediaId
        self.mediaType = type
        self.title = media.title
        self.originalTitle = media.originalTitle
        self.name = media.name
        self.originalName = media.originalName
        self.overview = media.overview
        self.voteAverage = media.voteAverage
        self.voteCount = media.voteCount
        self.posterPath = media.posterPath
        self.backdropPath = media.backdropPath
        self.genreIDs = media.genreIDS
        self.watched = watched
        self.personalRating = personalRating
        self.releaseDate = media.releaseDate
        self.firstAirDate = media.firstAirDate
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
}
