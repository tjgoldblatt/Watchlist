//
//  WatchlistManager.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/11/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBMedia: Codable {
    // Media
    let id: Int?
    let mediaType: MediaType?
    let title, originalTitle: String?
    let name, originalName: String?
    let overview: String?
    let voteAverage: Double?
    let voteCount: Int?
    let posterPath: String?
    let backdropPath: String?
    let genreIDS: [Int]?
    
    // Extra
    let watched: Bool
    let personalRating: Double?
    
    init?(media: Media, watched: Bool, personalRating: Double?) {
        guard let mediaId = media.id,
              let mediaType = media.mediaType else {
            return nil
        }
        self.id = mediaId
        self.mediaType = mediaType
        self.title = media.title
        self.originalTitle = media.originalTitle
        self.name = media.name
        self.originalName = media.originalName
        self.overview = media.overview
        self.voteAverage = media.voteAverage
        self.voteCount = media.voteCount
        self.posterPath = media.posterPath
        self.backdropPath = media.backdropPath
        self.genreIDS = media.genreIDS
        self.watched = watched
        self.personalRating = personalRating
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case mediaType
        case title
        case originalTitle
        case name
        case originalName
        case overview
        case voteAverage
        case voteCount
        case posterPath
        case backdropPath
        case genreIDS
        
        case watched
        case personalRating
    }
}

struct UserWatchlist: Codable {
    let userId: String
    @ServerTimestamp var lastUpdated: Date?
    
    init(userId: String, lastUpdated: Date?) {
        self.userId = userId
        self.lastUpdated = lastUpdated
    }
    
    enum CodingKeys: String, CodingKey {
        case userId
        case lastUpdated
    }
}

final class WatchlistManager {
    static let shared = WatchlistManager()
    private init() {}
    
    let watchlistCollection = Firestore.firestore().collection("watchlists")
    
    func watchlistDocument(userId: String) -> DocumentReference {
        watchlistCollection.document(userId)
    }
    
    func createWatchlistForUser(userId: String) async throws {
        let watchlist = UserWatchlist(userId: userId, lastUpdated: nil)
        try watchlistDocument(userId: userId).setData(from: watchlist, merge: false)
    }
    
    func getWatchlist(userID: String) async throws -> UserWatchlist {
        try await watchlistDocument(userId: userID).getDocument(as: UserWatchlist.self)
    }
    
    func deleteWatchlist(userId: String) async throws {
        try await watchlistDocument(userId: userId).delete()
    }
}

final class MediaManager {
    var userWatchlistCollection: CollectionReference? = nil
    
    init(userId: String) {
        self.userWatchlistCollection = Firestore.firestore()
            .collection("watchlists").document(userId)
            .collection("userWatchlist")
    }
    
    private func userWatchlistDocument(mediaId: Int) -> DocumentReference? {
        guard let userWatchlistCollection else { return nil }
        return userWatchlistCollection.document("\(mediaId)")
    }
    
    func deleteUserWatchlist() async throws {
        guard let userWatchlistCollection else { return }
        let snapshotDocuments = try await userWatchlistCollection.getDocuments().documents
        
        for snapshotDocument in snapshotDocuments {
            try await userWatchlistCollection.document(snapshotDocument.documentID).delete()
        }
    }
    
    func createNewMediaInWatchlist(media: Media) async throws {
        guard let mediaId = media.id,
              let userWatchlistDocument = userWatchlistDocument(mediaId: mediaId) else {
            throw URLError(.badURL)
        }
        
        let dbMedia = DBMedia(media: media, watched: false, personalRating: nil)
        try userWatchlistDocument.setData(from: dbMedia)
    }
    
    func toggleMediaWatched(mediaId: Int, watched: Bool) async throws {
        guard let userWatchlistDocument = userWatchlistDocument(mediaId: mediaId) else {
            throw URLError(.badURL)
        }
        
        let data: [String:Any] = [
            DBMedia.CodingKeys.watched.rawValue : watched
        ]
        
        try await userWatchlistDocument.updateData(data)
    }
}
