//
//  MediaModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/13/23.
//

import Foundation
import Blackbird

struct MediaModel: BlackbirdModel {
    @BlackbirdColumn var id: Int
    @BlackbirdColumn var title: String
    @BlackbirdColumn var watched: Bool
    @BlackbirdColumn var mediaType: String
    @BlackbirdColumn var personalRating: Double?
    @BlackbirdColumn var genreIDs: String?
    @BlackbirdColumn var media: Data
}
