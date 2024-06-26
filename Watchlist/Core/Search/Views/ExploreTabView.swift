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

    @State private var deepLinkMedia: DBMedia?
    @State private var showDeepLinkModal = false

    @State private var selectedThumbnail: DBMedia?

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background

                Color.theme.background.ignoresSafeArea()

                VStack(spacing: 10) {
                    header

                    searchBar

                    if vm.isLoaded {
                        if sortedSearchResults.isEmpty {
                            emptySearch
                        } else {
                            searchResultsView
                        }
                    } else {
                        Spacer()
                        ProgressView()
                    }

                    Spacer()
                }
                .onReceive(keyboardPublisher) { value in
                    isKeyboardShowing = value
                    isSubmitted = false
                }
            }
            .sheet(isPresented: $showDeepLinkModal) {
                if let deepLinkMedia {
                    GeometryReader { proxy in
                        MediaModalView(media: deepLinkMedia, size: proxy.size, safeArea: proxy.safeAreaInsets)
                            .ignoresSafeArea(.container, edges: .top)
                    }
                }
            }
            .onReceive(homeVM.$deepLinkURL) { url in
                if let url {
                    Task {
                        deepLinkMedia = await DeepLinkManager.parse(from: url, homeVM: homeVM)
                        showDeepLinkModal.toggle()
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Text("")
                }
            }
        }
        .analyticsScreen(name: "ExploreTabView")
        .onAppear {
            vm.loadMedia()
        }
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

    @ViewBuilder
    var searchResultsView: some View {
        if !vm.isSearching, homeVM.selectedTab == .explore {
            List {
                ForEach(sortedSearchResults, id: \.id) { media in
                    if media.posterPath != nil, let genreIds = media.genreIDs, !genreIds.isEmpty {
                        ExploreRowView(media: media, currentTab: .explore)
                            .listRowBackground(Color.theme.background)
                    }
                }
                .listRowBackground(Color.clear)
            }
            .background(.clear)
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .scrollDismissesKeyboard(.immediately)
        } else {
            ProgressView()
        }
    }

    var searchResults: [DBMedia] {
        let groupedMedia = homeVM.results.compactMap {
            try? DBMedia(media: $0, currentlyWatching: false, bookmarked: false, watched: false, personalRating: nil)
        }
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
            if homeVM.selectedSortingOption == .imdbRating {
                if let voteAverage1 = media1.voteAverage, let voteAverage2 = media2.voteAverage {
                    return voteAverage1 > voteAverage2
                }
            } else if homeVM.selectedSortingOption == .personalRating {
                if let personalRating1 = media1.personalRating, let personalRating2 = media2.personalRating {
                    return personalRating1 > personalRating2
                }
            }
            return false
        }
    }

    // MARK: - Empty Search

    @ViewBuilder
    private var emptySearch: some View {
        if homeVM.searchText.isEmpty {
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 10) {
                    ExploreThumbnailView(
                        title: "Trending Movies",
                        mediaArray: vm.trendingMovies,
                        selectedMedia: $selectedThumbnail
                    )

                    ExploreThumbnailView(
                        title: "Trending TV Shows",
                        mediaArray: vm.trendingTVShows,
                        selectedMedia: $selectedThumbnail
                    )

                    ExploreThumbnailView(
                        title: "Anticipated Movies",
                        mediaArray: vm.anticipatedMovies,
                        selectedMedia: $selectedThumbnail
                    )

                    ExploreThumbnailView(
                        title: "Anticipated TV Shows",
                        mediaArray: vm.anticipatedTVShows,
                        selectedMedia: $selectedThumbnail
                    )

                    ExploreThumbnailView(
                        title: "Top Rated Movies",
                        mediaArray: vm.topRatedMovies,
                        selectedMedia: $selectedThumbnail
                    )

                    ExploreThumbnailView(
                        title: "Top Rated TV Shows",
                        mediaArray: vm.topRatedTVShows,
                        selectedMedia: $selectedThumbnail
                    )
                }
                .padding()
                .sheet(item: $selectedThumbnail) { media in
                    GeometryReader {
                        MediaModalView(media: media, size: $0.size, safeArea: $0.safeAreaInsets)
                            .ignoresSafeArea(.container, edges: .top)
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
        } else {
            Text("No results found")
                .foregroundColor(Color.theme.text)
                .padding(.top)
        }
    }
}

struct ExploreThumbnailView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    var title: String
    var mediaArray: [DBMedia]

    @Binding var selectedMedia: DBMedia?

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .foregroundColor(Color.theme.text)
                    .fontWeight(.medium)
                    .fixedSize(horizontal: true, vertical: false)
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
                            Button {
                                selectedMedia = media
                            } label: {
                                ThumbnailView(imagePath: posterPath)
                                    .overlay(alignment: .topTrailing) {
                                        if homeVM.isMediaIDInWatchlist(for: media.id) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.theme.background)
                                                    .frame(width: 27, height: 27)

                                                Image(systemName: "checkmark.circle.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 20)
                                                    .foregroundStyle(Color.theme.genreText, Color.theme.red.gradient)
                                            }
                                            .offset(y: -5)
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding(.top, 5)
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ExploreTabView(homeVM: dev.homeVM)
                .previewDisplayName("Explore Tab View")
        }
        .preferredColorScheme(.dark)
        .environmentObject(dev.homeVM)

        ExploreThumbnailView(title: "", mediaArray: dev.mediaMock, selectedMedia: .constant(dev.mediaMock[0]))
            .environmentObject(dev.homeVM)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Explore Thumbnail View")
    }
}
