//
//  FilterOptions.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/2/23.
//

import Foundation

enum WatchOptions: String, CaseIterable {
    case unwatched = "Unwatched"
    case watched = "Watched"
    case any = "All"
}

enum SortingOptions: String, CaseIterable {
    case alphabetical = "Alphabetical"
    case imdbRating = "IMDb Rating"
    case personalRating = "Personal Rating"
}
