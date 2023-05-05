//
//  SeachDetailsViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Combine
import Foundation

@MainActor
final class SearchTabViewModel: ObservableObject {
    @Published var isSearching = false
	
    private var cancellables = Set<AnyCancellable>()
	
    var homeVM: HomeViewModel
	
    init(homeVM: HomeViewModel) {
        self.homeVM = homeVM
    }
	
    @MainActor
    func search() {
        isSearching = true
        TMDbService.search(with: homeVM.searchText)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: NetworkingManager.handleCompletition) { mediaArray in
                self.homeVM.results = mediaArray
                self.isSearching = false
            }
            .store(in: &cancellables)
    }
}
