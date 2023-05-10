//
//  TMDbService.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/11/23.
//

import Combine
import Foundation

class TMDbService {
    private init() {}
    
    /// Searches for a query
    /// - Parameters:
    ///   - query: Query from Search
    ///   - completion: code for what to do after task is finished
    static func search(with query: String) -> AnyPublisher<[Media], Error> {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }
        guard let url = URL(string: "\(Constants.baseURL)/3/search/multi?api_key=\(Constants.API_KEY)&query=\(query)&language=en-US&page=1&region=US") else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }
		
        return NetworkingManager.download(url: url)
            .decode(type: MediaResponse.self, decoder: JSONDecoder())
            .map(\.results)
            .eraseToAnyPublisher()
    }
    
    /// Fetches the list of all movie genres
    /// - Parameter completion: code for what to do after task is finished    
    static func getMovieGenreList() -> AnyPublisher<[Genre], Error> {
        guard let url = URL(string: "\(Constants.baseURL)/3/genre/movie/list?api_key=\(Constants.API_KEY)&language=en-US") else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }
        
        return NetworkingManager.download(url: url)
            .decode(type: GenreResponse.self, decoder: JSONDecoder())
            .map(\.genres)
            .eraseToAnyPublisher()
    }
    
    /// Fetches the list of all tv genres
    /// - Parameter completion: code for what to do after task is finished
    static func getTVGenreList() -> AnyPublisher<[Genre], Error> {
        guard let url = URL(string: "\(Constants.baseURL)/3/genre/tv/list?api_key=\(Constants.API_KEY)&language=en-US") else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }

        return NetworkingManager.download(url: url)
            .decode(type: GenreResponse.self, decoder: JSONDecoder())
            .map(\.genres)
            .eraseToAnyPublisher()
    }
}
