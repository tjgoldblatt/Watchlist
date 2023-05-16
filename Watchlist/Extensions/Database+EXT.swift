////
////  Database+Extension.swift
////  Watchlist
////
////  Created by TJ Goldblatt on 3/22/23.
////
//
//import Foundation
//import Blackbird
//
//extension Blackbird.Database {
//     TODO: Remove This
//    func upsert(model: some BlackbirdModel) async {
//        do {
//            try await model.write(to: self)
//        } catch {
//            CrashlyticsManager.handleError(error: error)
//        }
//    }
//    
//    func saveMedia(media: Media) {
//        Task {
//            if let id = media.id, let mediaType = media.mediaType {
//                var title = ""
//                
//                if mediaType == MediaType.tv, let mediaTitle = media.name {
//                    title = mediaTitle
//                } else if mediaType == MediaType.movie, let mediaTitle = media.title {
//                    title = mediaTitle
//                }
//                
//                var genreIDsToString: String? = nil
//                if let genreIDs = media.genreIDS {
//                    genreIDsToString = genreIDs.map({ String($0) }).joined(separator: ",")
//                }
//                
//                let mediaModel = MediaModel(id: id, title: title, watched: false, mediaType: mediaType.rawValue, personalRating: nil, genreIDs: genreIDsToString, media: try JSONEncoder().encode(media))
//                await upsert(model: mediaModel)
//            }
//        }
//    }
//    
//    func deleteMedia(media: Media) {
//        if let id = media.id {
//            deleteMediaByID(id: id)
//        }
//    }
//    
//    func deleteMediaByID(id: Int) {
//        Task {
//            guard let media = try await MediaModel.read(from: self, id: id) else { return }
//            try await media.delete(from: self)
//        }
//    }
//    
//    func fetchIsWatched(media: Media, completionHandler: @escaping (Bool) -> Void) async {
//        guard let id = media.id else { return }
//        
//        let fetchTask = Task { () -> Bool in
//            guard let mediaModel = try await MediaModel.read(from: self, id: id) else { return false }
//            return mediaModel.watched
//            
//        }
//        let result = await fetchTask.result
//        
//        do {
//            let watched = try result.get()
//            completionHandler(watched)
//        } catch {
//            CrashlyticsManager.handleError(error: error)
//        }
//    }
//    
//    
//    func fetchPersonalRating(media: Media, completionHandler: @escaping (Double?) -> Void) async {
//        guard let id = media.id else { return }
//        
//        let fetchTask = Task { () -> Double? in
//            guard let mediaModel = try await MediaModel.read(from: self, id: id) else { return nil }
//            let rating = mediaModel.personalRating
//            return rating
//        }
//        let result = await fetchTask.result
//        
//        do {
//            let rating = try result.get()
//            completionHandler(rating)
//        } catch {
//            CrashlyticsManager.handleError(error: error)
//        }
//    }
//    
//    func sendRating(rating: Double?, media: Media) async {
//        if let id = media.id {
//            do {
//                guard var mediaModel = try await MediaModel.read(from: self, id: id) else { return }
//                mediaModel.personalRating = rating
//                await upsert(model: mediaModel)
//            } catch {
//                CrashlyticsManager.handleError(error: error)
//            }
//        }
//    }
//    
//    func setWatched(watched: Bool, media: Media) async {
//        if let id = media.id {
//            do {
//                guard var mediaModel = try await MediaModel.read(from: self, id: id) else { return }
//                mediaModel.watched = watched
//                await upsert(model: mediaModel)
//            } catch {
//                CrashlyticsManager.handleError(error: error)
//            }
//        }
//    }
//}
