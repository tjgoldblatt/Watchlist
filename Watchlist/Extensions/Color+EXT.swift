//
//  Color.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let background = Color("BackgroundColor")
    let secondaryBackground = Color("SecondaryBackgroundColor")
    let red = Color("RedColor")
    let secondary = Color("SecondaryColor")
    let text = Color("TextColor")
    let genreText = Color("GenreTextColor")
}
