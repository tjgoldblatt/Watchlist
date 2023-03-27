//
//  Database+Extension.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/22/23.
//

import Foundation
import Blackbird

extension Blackbird.Database {
    
    func upsert(model: some BlackbirdModel) async {
        do {
            try await model.write(to: self)
        } catch {
            debugPrint(error)
        }
    }
    
    func saveMedia(media: Media) {
        Task {
            if let id = media.id, let mediaType = media.mediaType, let genreIDs = media.genreIDS {
                var title = ""
                if mediaType.rawValue == "tv", let mediaTitle = media.name {
                    title = mediaTitle
                } else if mediaType.rawValue == "movie", let mediaTitle = media.title {
                    title = mediaTitle
                }
                
                let genreIDsToString: String = genreIDs.map({ String($0) }).joined(separator: ",")
                
                let mediaModel = MediaModel(id: id, title: title, watched: false, mediaType: mediaType.rawValue, genreIDs: genreIDsToString, media: try JSONEncoder().encode(media))
                await upsert(model: mediaModel)
            }
        }
    }
    
    func deleteMedia(media: Media) {
        if let id = media.id {
            deleteMediaByID(id: id)
        }
    }
    
    func deleteMediaByID(id: Int) {
        Task {
            guard let media = try await MediaModel.read(from: self, id: id) else { return }
            debugPrint(media.id)
            try await media.delete(from: self)
        }
    }
    
    // MARK: - UI Changes on Main Thread
    @MainActor
    func fetchIsWatched(media: Media, completionHandler: @escaping (Bool) -> Void) async {
        guard let id = media.id else { return }
        
        let fetchTask = Task { () -> Bool in
            guard let mediaModel = try await MediaModel.read(from: self, id: id) else { return false }
            return mediaModel.watched
            
        }
        let result = await fetchTask.result
        
        do {
            let watched = try result.get()
            completionHandler(watched)
        } catch let error {
            debugPrint(error)
        }
    }
    
    @MainActor
    func fetchPersonalRating(media: Media, completionHandler: @escaping (Double?) -> Void) async {
        guard let id = media.id else { return }
        
        let fetchTask = Task { () -> Double? in
            guard let mediaModel = try await MediaModel.read(from: self, id: id) else { return nil }
            return mediaModel.personalRating
        }
        let result = await fetchTask.result
        
        do {
            let rating = try result.get()
            completionHandler(rating)
        } catch let error {
            debugPrint(error)
        }
    }
}
