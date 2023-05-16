//
//  ShapeStyle+EXT.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/8/23.
//

import Foundation
import SwiftUI

extension ShapeStyle where Self == Color {
    static var watchlistBackground: Color { Color("BackgroundColor") }
    static var watchlistSecondaryBackground: Color { Color("SecondaryBackgroundColor") }
    static var watchlistRed: Color { Color("RedColor") }
    static var watchlistSecondary: Color { Color("SecondaryColor") }
    static var watchlistText: Color { Color("TextColor") }
    static var watchlistGenreText: Color { Color("GenreTextColor") }
}

// let secondaryBackground = Color("BackgroundColor")
// let background = Color("SecondaryBackgroundColor")
// let red = Color("RedColor")
// let secondary = Color("SecondaryColor")
// let text = Color("TextColor")
// let genreText = Color("GenreTextColor")
