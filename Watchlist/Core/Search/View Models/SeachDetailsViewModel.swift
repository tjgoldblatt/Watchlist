//
//  SeachDetailsViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Foundation
import TMDb

class SearchDetailsViewModel: ObservableObject {
    @Published var results: [Media] = []
    @Published var isSearching = false
    @Published var searchText = ""
    
    @MainActor
    func executeQuery() async {
        isSearching = true
//        results = TMDbManager.shared.searchForMedia(for: searchText)
        Task {
            do {
                results = try await SearchDetailsViewModel.search(for: searchText)
                isSearching = false
            } catch {
                print("[🔥] Error While Searching")
            }
        }
    }
    
    static func search(for searchText: String) async throws -> [Media] {
        let media: [Media] = try await withCheckedThrowingContinuation({ continuation in
            TMDbService.search(with: searchText) { result in
                switch result {
                    case .success(let media):
                        continuation.resume(returning: media)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                }
            }
        })
        return media
    }
}
