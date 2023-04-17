//
//  WatchlistManager.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/11/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DBMedia: Codable, Identifiable, Hashable {
    // Media
    let id: Int
    let mediaType: MediaType?
    let title, originalTitle: String?
    let name, originalName: String?
    let overview: String?
    let voteAverage: Double?
    let voteCount: Int?
    let posterPath: String?
    let backdropPath: String?
    let genreIDs: [Int]?
    
    // Extra
    let watched: Bool
    let personalRating: Double?
    
    init(media: Media, watched: Bool, personalRating: Double?) {
        self.id = media.id ?? -1
        self.mediaType = media.mediaType
        self.title = media.title
        self.originalTitle = media.originalTitle
        self.name = media.name
        self.originalName = media.originalName
        self.overview = media.overview
        self.voteAverage = media.voteAverage
        self.voteCount = media.voteCount
        self.posterPath = media.posterPath
        self.backdropPath = media.backdropPath
        self.genreIDs = media.genreIDS
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
        case genreIDs
        
        case watched
        case personalRating
    }
}

struct UserWatchlist: Codable {
    let userId: String
    let isTransferred: Timestamp?
    @ServerTimestamp var lastUpdated: Timestamp?
    
    init(userId: String, lastUpdated: Timestamp?) {
        self.userId = userId
        self.lastUpdated = lastUpdated
        self.isTransferred = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case userId
        case isTransferred
        case lastUpdated
    }
}

final class WatchlistManager {
    static let shared = WatchlistManager()
    private init() {}
    
    // MARK: - Watchlist
    
    let watchlistCollection = Firestore.firestore().collection("watchlists")
    
    func watchlistDocument() throws -> DocumentReference {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        return watchlistCollection.document(authDataResult.uid)
    }
    
    func createWatchlistForUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        let watchlist = UserWatchlist(userId: authDataResult.uid, lastUpdated: Timestamp())
        try watchlistDocument().setData(from: watchlist, merge: true)
    }
    
    func getWatchlist() async throws -> UserWatchlist {
        try await watchlistDocument().getDocument(as: UserWatchlist.self)
    }
    
    func deleteWatchlist(userId: String) async throws {
        try await watchlistDocument().delete()
        try await deleteUserWatchlist()
    }
    
    func setTransferred() async throws {
        let watchlistDocument = try watchlistDocument()
        
        let data: [String:Any] = [
            UserWatchlist.CodingKeys.isTransferred.rawValue : FieldValue.serverTimestamp(),
        ]
        
        try await watchlistDocument.setData(data)
    }
    
    func getTransferred() async throws -> Timestamp? {
        let watchlistDocument = try watchlistDocument()
        
        let userWatchlist = try await watchlistDocument.getDocument(as: UserWatchlist.self)
        return userWatchlist.isTransferred
    }
    
    func updateLastUpdatedForUser() async throws {
        let watchlistDocument = try watchlistDocument()
        let data: [String:Any] = [
            UserWatchlist.CodingKeys.lastUpdated.rawValue : FieldValue.serverTimestamp()
        ]
        
        try await watchlistDocument.setData(data)
    }
    
    // MARK: - User Watchlist
    
    private func userWatchlistCollection() throws -> CollectionReference {
        try watchlistDocument().collection("userWatchlist")
    }
    
    private func userWatchlistDocument(mediaId: String) throws -> DocumentReference {
        try userWatchlistCollection().document(mediaId)
    }
    
    func deleteUserWatchlist() async throws {
        let snapshotDocuments = try await userWatchlistCollection().getDocuments().documents
        
        for snapshotDocument in snapshotDocuments {
            try await userWatchlistCollection().document(snapshotDocument.documentID).delete()
        }
    }
    
    func createNewMediaInWatchlist(media: DBMedia) async throws {
        let document = try userWatchlistCollection().document("\(media.id)")
        try document.setData(from: media)
        try await updateLastUpdatedForUser()
    }
    
    func deleteMediaInWatchlist(media: DBMedia) async throws {
        try await deleteMediaById(mediaId: media.id)
    }
    
    func deleteMediaById(mediaId: Int) async throws {
        try await userWatchlistDocument(mediaId: "\(mediaId)").delete()
        try await updateLastUpdatedForUser()
    }
    
    func setMediaWatched(media: DBMedia, watched: Bool) async throws {
        let userWatchlistDocument = try userWatchlistDocument(mediaId: "\(media.id)")
        
        let data: [String:Any] = [
            DBMedia.CodingKeys.watched.rawValue : watched
        ]
        try await updateLastUpdatedForUser()
        try await userWatchlistDocument.updateData(data)
    }
    
    func setPersonalRatingForMedia(media: DBMedia, personalRating: Double?) async throws {
        let userWatchlistDocument = try userWatchlistDocument(mediaId: "\(media.id)")
        
        let data: [String:Any] = [
            DBMedia.CodingKeys.personalRating.rawValue : personalRating ?? NSNull()
        ]
        try await updateLastUpdatedForUser()
        try await userWatchlistDocument.updateData(data)
    }
    
    func getUpdatedUserMedia(media: DBMedia) async throws -> DBMedia {
        let userWatchlistDocument = try userWatchlistDocument(mediaId: "\(media.id)")
        return try await userWatchlistDocument.getDocument(as: DBMedia.self)
    }
    
    func getUpdatedPersonalRating(media: DBMedia) async throws -> Double? {
        let user = try await getUpdatedUserMedia(media: media)
        return user.personalRating
    }
    
    func resetMedia(media: DBMedia) async throws {
        let userWatchlistDocument = try userWatchlistDocument(mediaId: "\(media.id)")
        
        let data: [String:Any] = [
            DBMedia.CodingKeys.personalRating.rawValue : NSNull(),
            DBMedia.CodingKeys.watched.rawValue : false,
        ]
        try await updateLastUpdatedForUser()
        try await userWatchlistDocument.updateData(data)
    }
    
    // MARK: - Fetch Movies/TV Shows
    
    func getMedia(mediaType: MediaType) async throws -> [DBMedia] {
        let query = try userWatchlistCollection()
            .whereField(DBMedia.CodingKeys.mediaType.rawValue, isEqualTo: mediaType.rawValue)
        
        return try await query
            .getDocuments(as: DBMedia.self)
    }

    // MARK: - Function to Copy from Blackbird to Firebase
    func copyBlackbirdToFBForUser(mediaModel: MediaModel) async throws {
        guard let media = try? JSONDecoder().decode(Media.self, from: mediaModel.media), let mediaId = media.id else { return }
        
        if media.mediaType == .movie && media.id == 1 { return }
            
        let dbMedia = DBMedia(media: media, watched: mediaModel.watched, personalRating: mediaModel.personalRating)
        let document = try userWatchlistCollection().document("\(mediaId)")
        try document.setData(from: dbMedia, merge: true)
    }
}

extension Query {
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        return try snapshot.documents.map { document in
            try document.data(as: T.self)
        }
    }
}
