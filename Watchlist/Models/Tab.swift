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
    case explore = "Explore"
    case social = "Social"
    
    var searchTextLabel: String {
        switch self {
            case .explore:
                return "Search for Movies or TV Shows..."
            case .tvShows:
                return "Search your saved TV Shows..."
            case .movies:
                return "Search your saved Movies..."
            case .social:
                return ""
        }
    }
    
    var icon: String {
        switch self {
            case .tvShows:
                return "tv"
            case .movies:
                return "popcorn.fill"
            case .explore:
                return "magnifyingglass"
            case .social:
                return "person.fill"
        }
    }
}
