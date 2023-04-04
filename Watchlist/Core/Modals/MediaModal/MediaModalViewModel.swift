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
    
    let mediaDetails: MediaDetailContents
    let media: Media
    
    var imagePath: String {
        if let backdropPath = mediaDetails.backdropPath {
            return backdropPath
        } else {
            return mediaDetails.posterPath
        }
    }
    
    init(mediaDetails: MediaDetailContents, media: Media) {
        self.mediaDetails = mediaDetails
        self.media = media
    }
}
