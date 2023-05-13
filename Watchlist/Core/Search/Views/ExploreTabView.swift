//
//  ExploreTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import FirebaseAnalyticsSwift
import NukeUI
import SwiftUI

struct ExploreTabView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    @StateObject private var vm: ExploreViewModel
    
    init(homeVM: HomeViewModel) {
        _vm = StateObject(wrappedValue: ExploreViewModel(homeVM: homeVM))
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
                        emptySearch
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
            if homeVM.sortingSelected == .imdbRating {
                if let voteAverage1 = media1.voteAverage, let voteAverage2 = media2.voteAverage {
                    return voteAverage1 > voteAverage2
                }
            } else if homeVM.sortingSelected == .personalRating {
                if let personalRating1 = media1.personalRating, let personalRating2 = media2.personalRating {
                    return personalRating1 > personalRating2
                }
            }
            return false
        }
    }
    
    // MARK: - Empty Search
    
    private var emptySearch: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                ExploreThumbnailView(title: "Trending Movies", mediaArray: vm.trendingMovies)
                
                ExploreThumbnailView(title: "Trending TV Shows", mediaArray: vm.trendingTVShows)
                
                ExploreThumbnailView(title: "Popular Movies", mediaArray: vm.popularMovies)
                
                ExploreThumbnailView(title: "Popular TV Shows", mediaArray: vm.popularTVShows)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

struct ExploreThumbnailView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @State var showingSheet = false
    
    var title: String
    var mediaArray: [DBMedia]
    
    @State var selectedMedia: DBMedia? = nil
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .foregroundColor(Color.theme.text)
                    .fontWeight(.medium)
                    .padding(.trailing, 5)
                Capsule()
                    .frame(height: 2)
                    .foregroundColor(Color.theme.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(mediaArray) { media in
                        if let posterPath = media.posterPath,
                           let overview = media.overview, !overview.isEmpty
                        {
                            ThumbnailView(imagePath: posterPath)
                                .overlay(alignment: .topTrailing) {
                                    if homeVM.isDBMediaInWatchlist(dbMedia: media) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20)
                                            .foregroundStyle(Color.theme.genreText, Color.theme.red)
                                            .offset(x: -15, y: 10)
                                    }
                                }
                                .onTapGesture {
                                    selectedMedia = media
                                    showingSheet.toggle()
                                }
                                .sheet(item: $selectedMedia) { media in
                                    MediaModalView(media: media)
                                }
                        }
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreTabView(homeVM: dev.homeVM)
            .environmentObject(dev.homeVM)
    }
}
