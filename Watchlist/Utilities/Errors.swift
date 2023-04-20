//
//  Errors.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/10/23.
//

import Foundation

enum FirebaseError: LocalizedError {
    case getAuthenticatedUser
    case getProviders
    case deleteUser
    case linkCredential
    
    case signInWithGoogle
    case signInWithApple(debugDescription: String = "")
    
    var errorDescription: String? {
        switch self {
            case .getAuthenticatedUser:
                return "[🔥] Failed to get authenticated user"
            case .getProviders:
                return "[🔥] Failed to get provider data"
            case .deleteUser:
                return "[🔥] Failed to delete User"
            case .linkCredential:
                return "[🔥] Failed to link user credential"
            case .signInWithGoogle:
                return "[🔥] Failed to sign in with Google"
            case .signInWithApple(let debugDescription):
                return "[🔥] Failed to sign in with Apple. \(debugDescription)"
        }
    }
}

enum NetworkError: LocalizedError {
    case decode(error: Error)
    case encode(error: Error)
    
    var errorDescription: String? {
        switch self {
            case .decode(let error):
                return "[💣] Failed to decode. \(error)"
            case .encode(let error):
                return "[💣] Failed to encode. \(error)"
        }
    }
}

enum TMDbError: LocalizedError {
    case failedToGetData
    case failedToEncodeData
    
    var errorDescription: String {
        switch self {
            case .failedToGetData:
                return "[💣] Failed to get data"
            case .failedToEncodeData:
                return "[💣] Failed to encode data"
        }
    }
}

