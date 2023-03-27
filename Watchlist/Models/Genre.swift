//
//  Genre.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/11/23.
//

import Foundation

struct GenreResponse: Codable {
    let genres: [Genre]
}

struct Genre: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}
