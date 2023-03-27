//
//  SeachDetailsViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Foundation

class SearchTabViewModel: ObservableObject {
    @Published var isSearching = false
    
    var homeVM: HomeViewModel
    
    init(homeVM: HomeViewModel) {
        self.homeVM = homeVM
    }
    
    @MainActor
    func search() async {
        isSearching = true
        
        Task {
            do {
                homeVM.results = try await SearchTabViewModel.search(for: homeVM.searchText)
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
