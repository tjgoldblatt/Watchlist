//
//  Errors.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/10/23.
//

import Foundation

enum ViewError: LocalizedError {
    /// Thrown when trying to create new row with Media
    case invalidMediaView(media: Media)
    
    case unknown
    
    var errorDescription: String? {
        switch self {
            case .invalidMediaView(media: let media): return "[🔥] Bad response from Media: \(media)"
            case .unknown: return "[⚠️] Unknown error occured"
        }
    }
}


enum FirebaseError: LocalizedError {
    // TODO: Make Errors for Firebase
}
