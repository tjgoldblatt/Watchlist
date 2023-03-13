//
//  TabBarItem.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Foundation
import SwiftUI

enum TabBarItem: Hashable {
    case home, search
    
    var iconName: String {
        switch self {
            case .home: return "film.stack"
            case .search: return "magnifyingglass"
        }
    }
    
    var title: String {
        switch self {
            case .home: return "Home"
            case .search: return "Search"
        }
    }
}
