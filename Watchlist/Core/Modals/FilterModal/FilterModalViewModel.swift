//
//  FilterModalViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/25/23.
//

import Foundation

@MainActor
final class FilterModalViewModel: ObservableObject {
    @Published var screenWidth: CGFloat = 0
    @Published var showWatchedModal = false
    @Published var genresSelected: Set<Genre> = []
}
