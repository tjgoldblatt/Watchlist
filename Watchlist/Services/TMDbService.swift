//
//  TMDbService.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/11/23.
//

import Foundation

enum TMDbError: LocalizedError {
    case failedToGetData
    
    var errorDescription: String {
        switch self {
            case .failedToGetData:
                return "[💣] Failed to get data"
        }
    }
}

class TMDbService {
    private init() { }
    
    /// Searches for a query
    /// - Parameters:
    ///   - query: Query from Search
    ///   - completion: code for what to do after task is finished
    static func search(with query: String, completion: @escaping (Result<[Media], Error>) -> Void) {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let url = URL(string: "\(Constants.baseURL)/3/search/multi?api_key=\(Constants.API_KEY)&query=\(query)&language=en-US&page=1") else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let results = try JSONDecoder().decode(MediaResponse.self, from: data)
                completion(.success(results.results))
            } catch {
                completion(.failure(TMDbError.failedToGetData))
            }
        }
        task.resume()
    }
    
    /// Fetches the list of all movie genres
    /// - Parameter completion: code for what to do after task is finished
    static func getMovieGenreList(completion: @escaping (Result<[Genre], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/3/genre/movie/list?api_key=\(Constants.API_KEY)&language=en-US") else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let results = try JSONDecoder().decode(GenreResponse.self, from: data)
                completion(.success(results.genres))
            } catch {
                completion(.failure(TMDbError.failedToGetData))
            }
        }
        task.resume()
    }
    
    /// Fetches the list of all tv genres
    /// - Parameter completion: code for what to do after task is finished
    static func getTVGenreList(completion: @escaping (Result<[Genre], Error>) -> Void) {
        guard let url = URL(string: "\(Constants.baseURL)/3/genre/tv/list?api_key=\(Constants.API_KEY)&language=en-US") else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let results = try JSONDecoder().decode(GenreResponse.self, from: data)
                completion(.success(results.genres))
            } catch {
                completion(.failure(TMDbError.failedToGetData))
            }
        }
        task.resume()
    }
    
}
