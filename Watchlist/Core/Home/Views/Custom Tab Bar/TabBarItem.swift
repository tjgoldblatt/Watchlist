//
//  TabBarItem.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Foundation
import SwiftUI

enum TabBarItem: Hashable {
    case movie, tvshow, search
    
    var iconName: String {
        switch self {
            case .movie: return Tab.movies.icon
            case .tvshow: return Tab.tvShows.icon
            case .search: return Tab.search.icon
        }
    }
    
    var title: String {
        switch self {
            case .movie: return Tab.movies.rawValue
            case .tvshow: return Tab.tvShows.rawValue
            case .search: return Tab.search.rawValue
        }
    }
}
