//
//  Post.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/13/23.
//

import Foundation
import Blackbird

struct Post: BlackbirdModel {
    @BlackbirdColumn var id: Int
    @BlackbirdColumn var watched: Bool
    @BlackbirdColumn var mediaType: String
    @BlackbirdColumn var media: Data
}
