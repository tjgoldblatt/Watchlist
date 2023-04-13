//
//  ShowsTabViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/12/23.
//

import SwiftUI

@MainActor
final class WatchlistDetailsViewModel: ObservableObject {
    /// Current filtered text
    @Published var filterText: String = ""
    
    @Published var isKeyboardShowing: Bool = false
    
    @Published var isSubmitted: Bool = false
    
    @Published var selectedRows = Set<Int>()
    
    @Published var deleteConfirmationShowing: Bool = false
    
    let emptyViewID = "HeaderView"
    
    func resetMedia(media: DBMedia) async throws {
        guard let id = media.id else { return }
        try await WatchlistManager.shared.resetMedia(mediaId: String(id))
    }
    
    func getWatchedSelectedRows(mediaList: [DBMedia]) ->[DBMedia] {
        var watchedSelectedRows: [DBMedia] = []
        
        for id in selectedRows {
            for media in mediaList.filter({ $0.id == id }) {
                if media.watched == true {
                    watchedSelectedRows.append(media)
                }
            }
        }
        
        return watchedSelectedRows
    }
    
//    func getWatchedSelectedRows(mediaModelArray: [MediaModel]) -> [MediaModel] {
//        var watchedSelectedRows: [MediaModel] = []
//        for id in selectedRows {
//            for mediaModel in mediaModelArray.filter({ $0.id == id }) {
//                if mediaModel.watched == true {
//                    watchedSelectedRows.append(mediaModel)
//                }
//            }
//        }
//        return watchedSelectedRows
//    }
}
