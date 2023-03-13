//
//  ShowsTabViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/12/23.
//

import SwiftUI

class ShowDetailsViewModel: ObservableObject {
    /// Current filtered text
    @Published var filterText: String = ""
}
