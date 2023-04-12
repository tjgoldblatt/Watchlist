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
    @ServerTimestamp var lastUpdated: Timestamp?
    
    init(userId: String, lastUpdated: Timestamp?) {
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
    
    private func userWatchlistCollection(userId: String) -> CollectionReference {
        watchlistDocument(userId: userId).collection("userWatchlist")
    }
    
    private func userWatchlistDocument(userId: String, mediaId: String) -> DocumentReference {
        userWatchlistCollection(userId: userId).document(mediaId)
    }
    
    // MARK: - Watchlist Functions
    
    func createWatchlistForUser(userId: String) async throws {
        let watchlist = UserWatchlist(userId: userId, lastUpdated: Timestamp())
        try watchlistDocument(userId: userId).setData(from: watchlist, merge: false)
    }
    
    func getWatchlist(userID: String) async throws -> UserWatchlist {
        try await watchlistDocument(userId: userID).getDocument(as: UserWatchlist.self)
    }
    
    func deleteWatchlist(userId: String) async throws {
        try await watchlistDocument(userId: userId).delete()
        try await deleteUserWatchlist(userId: userId)
    }
    
    // MARK: - User Watchlist Functions
    
    func deleteUserWatchlist(userId: String) async throws {
        let snapshotDocuments = try await userWatchlistCollection(userId: userId).getDocuments().documents
        
        for snapshotDocument in snapshotDocuments {
            try await userWatchlistCollection(userId: userId).document(snapshotDocument.documentID).delete()
        }
    }
    
    func createNewMediaInWatchlist(userId: String, media: Media) async throws {
        let document = userWatchlistCollection(userId: userId).document()
        let dbMedia = DBMedia(media: media, watched: false, personalRating: nil)
        try document.setData(from: dbMedia)
    }
    
    func toggleMediaWatched(userId: String, mediaId: Int, watched: Bool) async throws {
        let userWatchlistDocument = userWatchlistDocument(userId: userId, mediaId: "\(mediaId)")
        
        let data: [String:Any] = [
            DBMedia.CodingKeys.watched.rawValue : watched
        ]
        
        try await userWatchlistDocument.updateData(data)
    }
    
    func setPersonalRatingForMedia(userId: String, mediaId: Int, personalRating: Double) async throws {
        let userWatchlistDocument = userWatchlistDocument(userId: userId, mediaId: "\(mediaId)")
        
        let data: [String:Any] = [
            DBMedia.CodingKeys.personalRating.rawValue : personalRating
        ]
        
        try await userWatchlistDocument.updateData(data)
    }

    // MARK: - Function to Copy from Blackbird to Firebase
    func copyBlackbirdToFBForUser(mediaModel: MediaModel) async throws {
        guard let user = try? AuthenticationManager.shared.getAuthenticatedUser(),
              let media = try? JSONDecoder().decode(Media.self, from: mediaModel.media) else { return }
        
        if media.mediaType == .movie && media.id == 1 { return }
            
        let dbMedia = DBMedia(media: media, watched: mediaModel.watched, personalRating: mediaModel.personalRating)
        let document = userWatchlistCollection(userId: user.uid).document()
        try document.setData(from: dbMedia)
    }
}
