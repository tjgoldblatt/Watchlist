//
//  MediaDetailContents.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/14/23.
//

import Foundation

struct MediaDetailContents: Codable {
    let id: Int
    let posterPath: String
    let backdropPath: String?
    let title: String
    let genres: [Genre]?
    let overview: String
    let popularity: Double?
    
    let imdbRating: Double
    
    // TODO: For future work
    // Movie Specific
    //    let runTime: Int?
    
    // TV Show Specific
    //    let numberOfSeasons: Int?
    
}
