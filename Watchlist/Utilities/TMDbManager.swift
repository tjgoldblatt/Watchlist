//
//  TMDbManager.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/8/23.
//

import Foundation

class TMDbManager {
    
    static let shared = TMDbManager()
    
    static private var movieGenreList: [Genre] = []
    static private var tvGenreList: [Genre] = []
    
    /// Searches for media using the TMDbService with the given search term.
    /// - Parameter searchTerm: The search term to use.
    /// - Returns: An array of Media objects that match the search term.
    func searchForMedia(for searchTerm: String) -> [Media] {
        var mediaArray: [Media] = []
        
        let group = DispatchGroup()
        group.enter()
        
        TMDbService.search(with: searchTerm) { result in
            switch result {
                case .success(let mediaResponse):
                    mediaArray.append(contentsOf: mediaResponse)
                case .failure(let error):
                    CrashlyticsManager.handleError(error: error)
                    
            }
            group.leave()
        }
        group.wait()
        return mediaArray
    }
}
