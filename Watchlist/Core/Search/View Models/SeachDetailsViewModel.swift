//
//  SeachDetailsViewModel.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Foundation
import NaturalLanguage

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
                
                /// if we want only english titles
                /*
                let recognizer = NLLanguageRecognizer()
                homeVM.results = homeVM.results.filter { media in
                    guard let mediaType = media.mediaType else { return false }
                    switch mediaType {
                        case .movie:
                            if let title = media.originalTitle {
                                recognizer.processString(title)
                            }
                        case .tv:
                            if let name = media.originalName {
                                recognizer.processString(name)
                            }
                        case .person:
                            break
                    }
                 
                    return recognizer.dominantLanguage == .english
                }
                 */
                
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
