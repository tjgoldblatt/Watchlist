//
//  TMDbService.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/11/23.
//

import Combine
import Foundation

/// A service class that handles network requests to the TMDb API for media data.
class TMDbService {
    private init() { }

    /// Searches for a query
    /// - Parameters:
    ///   - query: Query from Search
    ///   - completion: code for what to do after task is finished
    static func search(with query: String) -> AnyPublisher<[Media], Error> {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }
        guard let url =
            URL(
                // swiftlint: disable line_length
                string: "\(TMDBConstants.baseURL)/3/search/multi?api_key=\(TMDBConstants.API_KEY)&query=\(query)&language=en-US&page=1&region=US"
                // swiftlint: enable line_length
            )
        else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }

        return NetworkingManager.download(url: url)
            .decode(type: MediaResponse.self, decoder: JSONDecoder())
            .map(\.results)
            .eraseToAnyPublisher()
    }

    /// This method retrieves the watch providers for a given media type and id.
    /// - Parameters:
    ///   - mediaType: The type of media (movie or tv show).
    ///   - id: The id of the media.
    /// - Returns: A publisher that emits the results of the API call or an error if the call fails.
    static func getWatchProviders(mediaType: MediaType, for id: Int) -> AnyPublisher<Results, Error> {
        guard let url =
            URL(string: "\(TMDBConstants.baseURL)/3/\(mediaType.rawValue)/\(id)/watch/providers?api_key=\(TMDBConstants.API_KEY)")
        else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }

        return NetworkingManager.download(url: url)
            .decode(type: WatchProvider.self, decoder: JSONDecoder())
            .compactMap(\.results)
            .eraseToAnyPublisher()
    }

    /// Fetches trending movies from the TMDb API.
    /// - Returns: A publisher that emits an array of `Media` objects or an error.
    static func getTrendingMovies() -> AnyPublisher<[Media], Error> {
        guard let url =
            URL(string: "\(TMDBConstants.baseURL)/3/trending/movie/week?api_key=\(TMDBConstants.API_KEY)&language=en-US")
        else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }

        return NetworkingManager.download(url: url)
            .decode(type: MediaResponse.self, decoder: JSONDecoder())
            .map(\.results)
            .eraseToAnyPublisher()
    }

    /// Fetches trending TV shows from the TMDb API.
    /// - Returns: A publisher that emits an array of `Media` objects or an error.
    static func getTrendingTVShows() -> AnyPublisher<[Media], Error> {
        guard let url = URL(string: "\(TMDBConstants.baseURL)/3/trending/tv/week?api_key=\(TMDBConstants.API_KEY)&language=en-US")
        else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }

        return NetworkingManager.download(url: url)
            .decode(type: MediaResponse.self, decoder: JSONDecoder())
            .map(\.results)
            .eraseToAnyPublisher()
    }

    static func getAnticipatedMedia(for media: MediaType) async throws -> [Int] {
        let urlMedia = media == .movie ? "movies" : "shows"
        guard let url = URL(string: "\(TraktConstants.BASE_URL)/\(urlMedia)/anticipated")
        else { throw TMDbError.failedToGetData }
        var request = URLRequest(url: url)
        request.setValue(TraktConstants.API_KEY, forHTTPHeaderField: "trakt-api-key")
        request.setValue("2", forHTTPHeaderField: "trakt-api-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw TMDbError.failedToGetData
        }

        if media == .tv {
            return try JSONDecoder().decode([TraktTV].self, from: data).compactMap { $0.show?.ids?.tmdb }
        } else {
            return try JSONDecoder().decode([TraktMovie].self, from: data).compactMap { $0.movie?.ids?.tmdb }
        }
    }

    static func convertTraktToTMDB(for media: MediaType) async throws -> [DBMedia] {
        do {
            let ids = try await getAnticipatedMedia(for: media)
            if media == .tv {
                var tvDetailArray: [DBMedia] = []
                for id in ids {
                    if let tvDetail = try? await getMediaDetails(media: .tv, for: id) as? TVDetails,
                       let tvShow = tvDetail.convertToMedia()
                    {
                        tvDetailArray.append(tvShow)
                    }
                }
                return tvDetailArray
            } else {
                var movieDetailArray: [DBMedia] = []
                for id in ids {
                    if let movieDetail = try? await getMediaDetails(media: .movie, for: id) as? MovieDetails,
                       let movie = movieDetail.convertToMedia()
                    {
                        movieDetailArray.append(movie)
                    }
                }
                return movieDetailArray
            }
        } catch {
            dump(error)
            CrashlyticsManager.handleError(error: error)
            throw error
        }
    }

    /// Fetches top rated movies from TMDb API.
    /// - Returns: A publisher that emits an array of `Media` objects or an error.
    static func getTopRatedMovies() -> AnyPublisher<[Media], Error> {
        guard let url = URL(string: "\(TMDBConstants.baseURL)/3/movie/top_rated?api_key=\(TMDBConstants.API_KEY)&language=en-US")
        else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }

        return NetworkingManager.download(url: url)
            .decode(type: MediaResponse.self, decoder: JSONDecoder())
            .map(\.results)
            .eraseToAnyPublisher()
    }

    /// Fetches top rated TV shows from TMDb API.
    /// - Returns: A publisher that emits an array of `Media` objects or an error.
    static func getTopRatedTVShows() -> AnyPublisher<[Media], Error> {
        guard let url = URL(string: "\(TMDBConstants.baseURL)/3/tv/top_rated?api_key=\(TMDBConstants.API_KEY)&language=en-US")
        else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }

        return NetworkingManager.download(url: url)
            .decode(type: MediaResponse.self, decoder: JSONDecoder())
            .map(\.results)
            .eraseToAnyPublisher()
    }

    /// Retrieves movie details for a given movie ID.
    /// - Parameter id: The ID of the movie to retrieve details for.
    /// - Returns: A publisher that emits a `MovieDetails` object or an error.
    static func getMovieDetails(for id: Int) -> AnyPublisher<MovieDetails, Error> {
        guard let url = URL(string: "\(TMDBConstants.baseURL)/3/movie/\(id)?api_key=\(TMDBConstants.API_KEY)&language=en-US")
        else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }

        return NetworkingManager.download(url: url)
            .decode(type: MovieDetails.self, decoder: JSONDecoder())
            .breakpointOnError()
            .catch { error -> AnyPublisher<MovieDetails, Error> in
                CrashlyticsManager.handleError(error: error)
                return Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Retrieves TV show details for a given TV show ID.
    /// - Parameter id: The ID of the TV show to retrieve details for.
    /// - Returns: A publisher that emits a `TVDetails` object or an error.
    static func getTVDetails(for id: Int) -> AnyPublisher<TVDetails, Error> {
        guard let url = URL(string: "\(TMDBConstants.baseURL)/3/tv/\(id)?api_key=\(TMDBConstants.API_KEY)&language=en-US")
        else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }

        return NetworkingManager.download(url: url)
            .decode(type: TVDetails.self, decoder: JSONDecoder())
            .breakpointOnError()
            .catch { error -> AnyPublisher<TVDetails, Error> in
                CrashlyticsManager.handleError(error: error)
                return Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    static func getMediaDetails(media: MediaType, for id: Int) async throws -> MediaDetails {
        guard let url =
            URL(string: "\(TMDBConstants.baseURL)/3/\(media.rawValue)/\(id)?api_key=\(TMDBConstants.API_KEY)&language=en-US")
        else { throw TMDbError.failedToGetData }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw TMDbError.failedToGetData }

        if media == .tv {
            return try JSONDecoder().decode(TVDetails.self, from: data)
        } else {
            return try JSONDecoder().decode(MovieDetails.self, from: data)
        }
    }

    /// Fetches the list of all movie genres
    /// - Parameter completion: code for what to do after task is finished
    static func getMovieGenreList() -> AnyPublisher<[Genre], Error> {
        guard let url = URL(string: "\(TMDBConstants.baseURL)/3/genre/movie/list?api_key=\(TMDBConstants.API_KEY)&language=en-US")
        else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }

        return NetworkingManager.download(url: url)
            .decode(type: GenreResponse.self, decoder: JSONDecoder())
            .map(\.genres)
            .eraseToAnyPublisher()
    }

    /// Fetches the list of all tv genres
    /// - Parameter completion: code for what to do after task is finished
    static func getTVGenreList() -> AnyPublisher<[Genre], Error> {
        guard let url = URL(string: "\(TMDBConstants.baseURL)/3/genre/tv/list?api_key=\(TMDBConstants.API_KEY)&language=en-US")
        else { return Fail(error: TMDbError.failedToGetData).eraseToAnyPublisher() }

        return NetworkingManager.download(url: url)
            .decode(type: GenreResponse.self, decoder: JSONDecoder())
            .map(\.genres)
            .eraseToAnyPublisher()
    }
}

// MARK: - Helper

extension TMDbService {
    static func addOrSubtractMonth(month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Calendar.current.date(byAdding: .month, value: month, to: Date()) ?? Date())
    }
}
