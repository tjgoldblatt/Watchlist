//
//  WatchlistManager.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/11/23.
//

import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

final class WatchlistManager {
    static let shared = WatchlistManager()
    private init() { }

    // MARK: - Watchlist

    let watchlistCollection = Firestore.firestore().collection("watchlists")

    /// Returns the Firestore document reference for the user's watchlist.
    /// - Throws: An error if the user is not authenticated.
    /// - Returns: The Firestore document reference for the user's watchlist.
    func watchlistDocument() throws -> DocumentReference {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        return watchlistCollection.document(authDataResult.uid)
    }

    func watchlistDocument(userId: String) throws -> DocumentReference {
        return watchlistCollection.document(userId)
    }

    /// Creates a new watchlist for the authenticated user.
    /// - Throws: An error if the user is not authenticated or if the watchlist creation fails.
    func createWatchlistForUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        let watchlist = UserWatchlist(
            userId: authDataResult.uid,
            displayName: authDataResult.displayName,
            lastUpdated: Timestamp()
        )
        try watchlistDocument().setData(from: watchlist, merge: true)
    }

    /// Retrieves the user's watchlist from Firestore.
    /// - Throws: An error if the watchlist retrieval fails.
    /// - Returns: The user's watchlist.
    func getWatchlist() async throws -> UserWatchlist {
        try await watchlistDocument().getDocument(as: UserWatchlist.self)
    }

    /// Deletes the user's watchlist from Firestore.
    /// - Throws: An error if the watchlist deletion or the user's watchlist deletion fails.
    func deleteWatchlist() async throws {
        try await watchlistDocument().delete()
        try await deleteUserWatchlist()
    }

    func deleteWatchlist(userId: String) async throws {
        try await watchlistDocument(userId: userId).delete()
        try await deleteWatchlist(userId: userId)
    }

    /// Sets the display name of the user in the watchlist document.
    func setDisplayName() async throws {
        let watchlistDocument = try watchlistDocument()
        let user = try await UserManager.shared.getUser()

        guard let displayName = user.displayName else {
            return
        }

        let data: [String: Any] = [
            UserWatchlist.CodingKeys.displayName.rawValue: displayName.capitalized,
        ]

        try await watchlistDocument.setData(data, merge: true)
    }

    /// Gets the isTransferred field value of the watchlist document.
    /// - Returns: The timestamp value of the isTransferred field.
    func getTransferred() async throws -> Timestamp? {
        let watchlistDocument = try watchlistDocument()

        let userWatchlist = try await watchlistDocument.getDocument(as: UserWatchlist.self)
        return userWatchlist.isTransferred
    }

    /// Updates the lastUpdated field of the watchlist document and sets the display name of the user.
    func updateLastUpdatedForUser() async throws {
        let watchlistDocument = try watchlistDocument()
        let data: [String: Any] = [
            UserWatchlist.CodingKeys.lastUpdated.rawValue: FieldValue.serverTimestamp(),
        ]

        try await setDisplayName()
        try await watchlistDocument.setData(data, merge: true)
    }

    // MARK: - User Watchlist

    /// Returns the userWatchlist collection reference.
    private func userWatchlistCollection() throws -> CollectionReference {
        try watchlistDocument().collection("userWatchlist")
    }

    /// Returns the userWatchlist document reference for the given media id.
    /// - Parameter mediaId: The id of the media.
    private func userWatchlistDocument(mediaId: String) throws -> DocumentReference {
        try userWatchlistCollection().document(mediaId)
    }

    /// Deletes all the documents in the userWatchlist collection.
    func deleteUserWatchlist() async throws {
        let snapshotDocuments = try await userWatchlistCollection().getDocuments().documents

        for snapshotDocument in snapshotDocuments {
            try await userWatchlistCollection().document(snapshotDocument.documentID).delete()
        }
    }

    /// Creates a new media document in the userWatchlist collection with the data from the given media object.
    /// - Parameter media: The media object to be added to the watchlist.
    func createNewMediaInWatchlist(media: DBMedia) async throws {
        let document = try userWatchlistCollection().document("\(media.id)")
        try document.setData(from: media, merge: true)
        try await updateLastUpdatedForUser()
    }

    /// Checks if a given media exists in the userWatchlist collection.
    /// - Parameter media: The media object to be checked.
    /// - Returns: A boolean value indicating whether the media document exists in the collection or not.
    func doesMediaExistInCollection(media: DBMedia) async throws -> Bool {
        let userWatchlistDocument = try userWatchlistDocument(mediaId: "\(media.id)")
        let documentSnapshot = try await userWatchlistDocument.getDocument()
        return documentSnapshot.exists
    }

    /// Deletes a media from the user's watchlist.
    /// - Parameter media: The media to be deleted.
    func deleteMediaInWatchlist(media: DBMedia) async throws {
        try await deleteMediaById(mediaId: media.id)
    }

    /// Deletes a media from the user's watchlist by its ID.
    /// - Parameter mediaId: The ID of the media to be deleted.
    func deleteMediaById(mediaId: Int) async throws {
        try await userWatchlistDocument(mediaId: "\(mediaId)").delete()
        try await updateLastUpdatedForUser()
    }

    /// Updates the "currentlyWatching" property of a media item in the user's watchlist.
    /// - Parameters:
    ///   - media: The media item to update.
    ///   - currentlyWatching: The new value for the "currentlyWatching" property.
    /// - Throws: An error if the update operation fails.
    func setMediaCurrentlyWatching(media: DBMedia, currentlyWatching: Bool) async throws {
        let userWatchlistDocument = try userWatchlistDocument(mediaId: "\(media.id)")

        let data: [String: Any] = [
            DBMedia.CodingKeys.currentlyWatching.rawValue: currentlyWatching,
        ]
        try await updateLastUpdatedForUser()
        try await userWatchlistDocument.updateData(data)
    }

    /// Updates the "bookmarked" property of a media item in the user's watchlist.
    /// - Parameters:
    ///   - media: The media item to update.
    ///   - bookmarked: The new value for the "bookmarked" property.
    /// - Throws: An error if the update operation fails.
    func setMediaBookmarked(media: DBMedia, bookmarked: Bool) async throws {
        let userWatchlistDocument = try userWatchlistDocument(mediaId: "\(media.id)")

        let data: [String: Any] = [
            DBMedia.CodingKeys.bookmarked.rawValue: bookmarked,
        ]
        try await updateLastUpdatedForUser()
        try await userWatchlistDocument.updateData(data)
    }

    /// Sets the watched status of a media.
    /// - Parameters:
    ///   - media: The media to be updated.
    ///   - watched: The new watched status.
    func setMediaWatched(media: DBMedia, watched: Bool) async throws {
        let userWatchlistDocument = try userWatchlistDocument(mediaId: "\(media.id)")

        let data: [String: Any] = [
            DBMedia.CodingKeys.watched.rawValue: watched,
        ]

        if media.currentlyWatching, watched {
            try await setMediaCurrentlyWatching(media: media, currentlyWatching: false)
        }

        try await updateLastUpdatedForUser()
        try await userWatchlistDocument.updateData(data)
    }

    /// Sets the personal rating of a media.
    /// - Parameters:
    ///   - media: The media to be updated.
    ///   - personalRating: The new personal rating.
    func setPersonalRatingForMedia(media: DBMedia, personalRating: Double?) async throws {
        let userWatchlistDocument = try userWatchlistDocument(mediaId: "\(media.id)")

        let data: [String: Any] = [
            DBMedia.CodingKeys.personalRating.rawValue: personalRating ?? NSNull(),
        ]
        try await updateLastUpdatedForUser()
        try await userWatchlistDocument.updateData(data)
    }

    func updateMediaInWatchlist(media: DBMedia) async throws {
        let document = try userWatchlistCollection().document("\(media.id)")
        try document.setData(from: media, merge: true)
    }

    /// Sets the release or air date of a media.
    /// - Parameter media: The media to be updated.
    func setReleaseOrAirDateForMedia(media: DBMedia) async throws {
        let userWatchlistDocument = try userWatchlistDocument(mediaId: "\(media.id)")

        var data: [String: Any] = [:]
        if media.mediaType == .movie {
            data = [
                DBMedia.CodingKeys.releaseDate.rawValue: media.releaseDate ?? NSNull(),
            ]
        } else if media.mediaType == .tv {
            data = [
                DBMedia.CodingKeys.firstAirDate.rawValue: media.firstAirDate ?? NSNull(),
            ]
        }

        try await updateLastUpdatedForUser()
        try await userWatchlistDocument.updateData(data)
    }

    /// Resets the personal rating and watched status of a media.
    /// - Parameter media: The media to be reset.
    func resetMedia(media: DBMedia) async throws {
        let userWatchlistDocument = try userWatchlistDocument(mediaId: "\(media.id)")

        let data: [String: Any] = [
            DBMedia.CodingKeys.personalRating.rawValue: NSNull(),
            DBMedia.CodingKeys.watched.rawValue: false,
        ]
        try await updateLastUpdatedForUser()
        try await userWatchlistDocument.updateData(data)
    }

    // MARK: - Fetch Movies/TV Shows

    /// Fetches all media of a given type from the user's watchlist.
    /// - Parameter mediaType: The type of media to fetch.
    /// - Returns: An array of `DBMedia` objects representing the user's watchlist.
    func getMedia(mediaType: MediaType, forUser userId: String? = nil) async throws -> [DBMedia] {
        var watchlistCollection = try userWatchlistCollection()

        if let userId {
            watchlistCollection = userWatchlistCollection(for: userId)
        }

        let query = watchlistCollection
            .whereField(DBMedia.CodingKeys.mediaType.rawValue, isEqualTo: mediaType.rawValue)

        return try await query
            .getDocuments(as: DBMedia.self)
    }

    /// Adds a snapshot listener to the user's watchlist collection, which returns a publisher for the latest watchlist data.
    /// - Returns: A tuple containing an `AnyPublisher` for the latest watchlist data and a `ListenerRegistration` object to
    /// remove the listener.
    func addListenerForGetMedia() throws -> (AnyPublisher<[DBMedia], Error>, ListenerRegistration) {
        return try userWatchlistCollection()
            .addSnapshotListener(as: DBMedia.self)
    }
}

// MARK: - Social

extension WatchlistManager {
    func getWatchlistDocument(for userId: String) -> DocumentReference {
        return watchlistCollection.document(userId)
    }

    func getWatchlist(for userId: String) async throws -> UserWatchlist {
        try await getWatchlistDocument(for: userId).getDocument(as: UserWatchlist.self)
    }

    /// Returns the userWatchlist collection reference.
    func userWatchlistCollection(for userId: String) -> CollectionReference {
        getWatchlistDocument(for: userId).collection("userWatchlist")
    }
}
