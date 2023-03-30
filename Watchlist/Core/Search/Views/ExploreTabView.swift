//
//  ExploreTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI
import Blackbird

struct ExploreTabView: View {
    @Environment(\.blackbirdDatabase) var database
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    var vm: SearchTabViewModel {
        SearchTabViewModel(homeVM: homeVM)
    }
    
    @State var rowViewManager: RowViewManager
    
    @State var isKeyboardShowing: Bool = false
    @State var isSubmitted: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                Color.theme.background.ignoresSafeArea()
                
                VStack {
                    header
                    
                    searchBar
                    
                    searchResults
                    
                    Spacer()
                }
                .onReceive(keyboardPublisher) { value in
                    isKeyboardShowing = value
                    isSubmitted = false
                }
            }
        }
        .onAppear { homeVM.getMediaWatchlists() }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreTabView(rowViewManager: RowViewManager(homeVM: dev.homeVM))
            .environmentObject(dev.homeVM)
    }
}

extension ExploreTabView {
    var header: some View {
        HeaderView(currentTab: .constant(.explore), showIcon: true)
            .padding(.horizontal)
    }
    
    var searchBar: some View {
        SearchBarView(searchText: $homeVM.searchText, genres: ["Action", "Science Fiction"]) {
            Task {
                await vm.search()
            }
        }
        .padding(.bottom)
    }
    
    var searchResults: some View {
        if !vm.isSearching {
            return AnyView(
                List {
                    ForEach(sortedSearchResults, id: \.id) { media in
                        rowViewManager.createRowView(media: media, tab: .explore)
                    }
                    .listRowBackground(Color.clear)
                }
                    .toolbar {
                        Text("")
                    }
                    .scrollIndicators(.hidden)
                    .listStyle(.plain)
                    .scrollDismissesKeyboard(.immediately)
            )
        } else {
            return AnyView(ProgressView())
        }
    }
    var sortedSearchResults: [Media] {
        let groupedMedia = homeVM.results
        if !homeVM.genresSelected.isEmpty || homeVM.ratingSelected > 0 {
            var filteredMedia = groupedMedia
            
            /// Genre Filter
            if !homeVM.genresSelected.isEmpty {
                filteredMedia = filteredMedia.filter { media in
                    guard let genreIDs = media.genreIDS else { return false }
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
}
