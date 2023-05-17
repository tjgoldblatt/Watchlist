//
//  NetworkingManager.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/4/23.
//

import Combine
import FirebaseCrashlytics
import Foundation

class NetworkingManager {
    enum NetworkingError: LocalizedError {
        case badURLResponse(url: URL)
        case unknown

        var errorDescription: String? {
            switch self {
                case let .badURLResponse(url: url): return "[🔥] Bad response from URL: \(url)"
                case .unknown: return "[⚠️] Unknown error occured"
            }
        }
    }

    static func download(url: URL) -> AnyPublisher<Data, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .default))
            .tryMap { try handleURLResponse(output: $0, url: url) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    static func handleURLResponse(output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse,
              response.statusCode >= 200, response.statusCode < 300
        else {
            throw NetworkingError.badURLResponse(url: url)
        }

        return output.data
    }

    static func handleCompletition(completition: Subscribers.Completion<Error>) {
        switch completition {
            case .finished:
                break
            case let .failure(error):
                Crashlytics.crashlytics().record(error: error)
        }
    }
}
