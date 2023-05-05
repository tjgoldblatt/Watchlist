//
//  ExploreTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import FirebaseAnalyticsSwift
import SwiftUI

struct ExploreTabView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    var vm: SearchTabViewModel {
        SearchTabViewModel(homeVM: homeVM)
    }
    
    @State var isKeyboardShowing: Bool = false
    @State var isSubmitted: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background

                Color.theme.background.ignoresSafeArea()
                
                VStack(spacing: 10) {
                    header
                    
                    searchBar
                    
                    if sortedSearchResults.isEmpty {
                        Color.theme.background
                    } else {
                        searchResultsView
                    }
                    
                    Spacer()
                }
                .onReceive(keyboardPublisher) { value in
                    isKeyboardShowing = value
                    isSubmitted = false
                }
            }
            .toolbar {
                Text("")
            }
        }
        .analyticsScreen(name: "ExploreTabView")
    }
}

extension ExploreTabView {
    // MARK: - Header

    var header: some View {
        NavigationStack {
            HeaderView(currentTab: .constant(.explore), showIcon: true)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Search

    var searchBar: some View {
        SearchBarView(searchText: $homeVM.searchText) {
            vm.search()
        }
        .padding(.bottom)
    }
    
    // MARK: - Search Results

    var searchResultsView: some View {
        if !vm.isSearching && homeVM.selectedTab == .explore {
            return AnyView(
                List {
                    ForEach(sortedSearchResults, id: \.id) { media in
                        if let _ = media.posterPath, let genreIds = media.genreIDs, !genreIds.isEmpty {
                            ExploreRowView(media: media, currentTab: .explore)
                                .listRowBackground(Color.theme.background)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .background(.clear)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .listStyle(.plain)
                .scrollDismissesKeyboard(.immediately)
            )
        } else {
            return AnyView(ProgressView())
        }
    }
    
    var searchResults: [DBMedia] {
        let groupedMedia = homeVM.results.map { DBMedia(media: $0, watched: false, personalRating: nil) }
        if !homeVM.genresSelected.isEmpty || homeVM.ratingSelected > 0 {
            var filteredMedia = groupedMedia
            
            /// Genre Filter
            if !homeVM.genresSelected.isEmpty {
                filteredMedia = filteredMedia.filter { media in
                    guard let genreIDs = media.genreIDs else { return false }
                    for selectedGenre in homeVM.genresSelected {
                        return genreIDs.contains(selectedGenre.id)
                    }
                    return false
                }
            }
            
            /// Rating Filter
            filteredMedia = filteredMedia.filter { media in
                if let voteAverage = media.voteAverage {
                    return voteAverage > Double(homeVM.ratingSelected)
                }
                return false
            }
            
            return filteredMedia
            
        } else {
            return groupedMedia
        }
    }
    
    var sortedSearchResults: [DBMedia] {
        return searchResults.sorted { media1, media2 in
            if homeVM.sortingSelected == .highToLow {
                if let voteAverage1 = media1.voteAverage, let voteAverage2 = media2.voteAverage {
                    return voteAverage1 > voteAverage2
                }
            } else if homeVM.sortingSelected == .lowToHigh {
                if let voteAverage1 = media1.voteAverage, let voteAverage2 = media2.voteAverage {
                    return voteAverage1 < voteAverage2
                }
            }
            return false
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreTabView()
            .environmentObject(dev.homeVM)
    }
}
