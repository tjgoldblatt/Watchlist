//
//  ShowsTabViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/12/23.
//

import SwiftUI

class WatchlistDetailsViewModel: ObservableObject {
    /// Current filtered text
    @Published var filterText: String = ""
    
    @Published var isKeyboardShowing: Bool = false
    
    @Published var isSubmitted: Bool = false
    
    @Published var selectedRows = Set<Int>()
    
    @Published var deleteConfirmationShowing: Bool = false
    
    let emptyViewID = "HeaderView"
    
    func getWatchedSelectedRows(mediaModelArray: [MediaModel]) -> [MediaModel] {
        var watchedSelectedRows: [MediaModel] = []
        for id in selectedRows {
            for mediaModel in mediaModelArray.filter({ $0.id == id }) {
                if mediaModel.watched == true {
                    watchedSelectedRows.append(mediaModel)
                }
            }
        }
        return watchedSelectedRows
    }
}
