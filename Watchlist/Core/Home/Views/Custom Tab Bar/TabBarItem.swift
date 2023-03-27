//
//  TabBarItem.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Foundation
import SwiftUI

enum TabBarItem: Hashable {
    case movie, tvshow, explore
    
    var iconName: String {
        switch self {
            case .movie: return Tab.movies.icon
            case .tvshow: return Tab.tvShows.icon
            case .explore: return Tab.explore.icon
        }
    }
    
    var title: String {
        switch self {
            case .movie: return Tab.movies.rawValue
            case .tvshow: return Tab.tvShows.rawValue
            case .explore: return Tab.explore.rawValue
        }
    }
}
