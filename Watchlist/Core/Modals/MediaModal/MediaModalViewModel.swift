//
//  MediaModalViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/4/23.
//

import Foundation

class MediaModalViewModel: ObservableObject {
    @Published var isAdded = false
    @Published var isWatched = false
    
    @Published var personalRating: Double?
    
    @Published var showingRating = false
    @Published var showDeleteConfirmation = false
    
    @Published var selectedOption: String = "Clear Rating"
    let options = ["Clear Rating"]
    
//    let mediaDetails: MediaDetailContents
    let media: DBMedia
    
    var imagePath: String {
        if let backdropPath = media.backdropPath {
            return backdropPath
        } else if let posterPath = media.posterPath {
            return posterPath
        } else {
            return ""
        }
    }
    
    init(media: DBMedia) {
        self.media = media
    }
}
