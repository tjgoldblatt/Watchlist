//
//  SeachDetailsViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Foundation
import Combine

class SearchTabViewModel: ObservableObject {
    @Published var isSearching = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var homeVM: HomeViewModel
    
    init(homeVM: HomeViewModel) {
        self.homeVM = homeVM
    }
    
    @MainActor
    func search() async {
        isSearching = true
        homeVM.$searchText
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { searchText in
                Task { [weak self] in
                    guard let self else { return }
                    do {
                        self.homeVM.results = try await SearchTabViewModel.search(for: searchText)
                        self.isSearching = false
                    } catch {
                        print("[🔥] Error While Searching")
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    static func search(for searchText: String) async throws -> [Media] {
        let media: [Media] = try await withCheckedThrowingContinuation { continuation in
            TMDbService.search(with: searchText) { result in
                switch result {
                    case .success(let media):
                        continuation.resume(returning: media)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                }
            }
        }
        return media
    }
}
