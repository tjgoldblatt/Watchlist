//
//  Tab.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI

/// Tabs at the Bottom of the Screen
/// Shows and Search
enum Tab: String {
    case tvShows = "TV Shows"
    case movies = "Movies"
    case search = "Search"
    
    var searchTextLabel: String {
        switch self {
            case .search:
                return "Search for Movies or TV Shows..."
            case .tvShows:
                return "Search for TV Shows..."
            case .movies:
                return "Search for Movies..."
        }
    }
    
    var icon: String {
        switch self {
            case .tvShows:
                return "tv.fill"
            case .movies:
                return "popcorn.fill"
            case .search:
                return "magnifyingglass"
        }
    }
}
