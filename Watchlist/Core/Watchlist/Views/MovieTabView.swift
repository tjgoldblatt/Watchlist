//
//  MovieTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import FirebaseAnalyticsSwift
import SwiftUI

struct MovieTabView: View {
    @EnvironmentObject private var homeVM: HomeViewModel

    @StateObject var vm = WatchlistDetailsViewModel()

    @Namespace private var animation

    var watchedSelectedRows: [DBMedia] {
        return vm.getWatchedSelectedRows(mediaList: homeVM.movieList)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background

                Color.theme.background.ignoresSafeArea()

                ScrollViewReader { proxy in
                    VStack(spacing: 10) {
                        header

                        searchbar

                        // MARK: - Watchlist

                        if !homeVM.movieList.isEmpty {
                            watchFilterOptions
                                .disabled(vm.editMode == .active)
                        }

                        if !sortedSearchResults.isEmpty {
                            watchlist(scrollProxy: proxy)
                        } else {
                            if homeVM.isMediaLoaded {
                                EmptyListView()
                            } else {
                                Spacer()
                                ProgressView()
                            }
                        }

                        Spacer()
                    }
                }
                .onChange(of: homeVM.selectedTab) { _ in
                    vm.filterText = ""
                }
            }
            .toolbar {
                ToolbarItem {
                    Text("")
                }
            }
        }
        .analyticsScreen(name: "MovieTabView")
    }
}

extension MovieTabView {
    // MARK: - Header

    var header: some View {
        HeaderView(currentTab: .constant(.movies), showIcon: true)
            .transition(.slide)
            .padding(.horizontal)
    }

    // MARK: - Search

    var searchbar: some View {
        SearchBarView(searchText: $vm.filterText)
            .disabled(vm.editMode == .active)
    }

    // MARK: - Watchlist

    func watchlist(scrollProxy: ScrollViewProxy) -> some View {
        List(selection: $vm.selectedRows) {
            ForEach(sortedSearchResults) { movie in
                RowView(media: movie)
                    .allowsHitTesting(vm.editMode == .inactive)
                    .listRowBackground(Color.theme.background)
            }
            .id(vm.emptyViewID)
            .onChange(of: homeVM.selectedWatchOption) { _ in
                if sortedSearchResults.count > 3 {
                    scrollProxy.scrollTo(vm.emptyViewID, anchor: .top)
                }
            }
            .listRowBackground(Color.theme.background)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !sortedSearchResults.isEmpty {
                    Button(vm.editMode == .active ? "Done" : "Edit") {
                        if vm.editMode == .active {
                            withAnimation(.spring()) {
                                vm.editMode = .inactive
                                homeVM.editMode = .inactive
                            }
                        } else {
                            withAnimation(.spring()) {
                                vm.editMode = .active
                                homeVM.editMode = .active
                            }
                        }
                    }
                    .foregroundColor(Color.theme.red)
                    .padding()
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                }
            }

            if !watchedSelectedRows.isEmpty, vm.editMode == .active {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Reset")
                        .font(.body)
                        .foregroundColor(Color.theme.red)
                        .padding()
                        .onTapGesture {
                            AnalyticsManager.shared.logEvent(name: "MovieTabView_ResetMedia")
                            Task {
                                for watchedSelectedRow in watchedSelectedRows {
                                    try await WatchlistManager.shared.resetMedia(media: watchedSelectedRow)
                                }
                                vm.selectedRows = []
                                vm.editMode = .inactive
                                homeVM.editMode = .inactive
                            }
                        }
                }
            }
        }
        .background(.clear)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, $vm.editMode)
        .overlay(alignment: .bottomTrailing) {
            if !vm.selectedRows.isEmpty, vm.editMode == .active {
                Image(systemName: "trash.circle.fill")
                    .resizable()
                    .fontWeight(.bold)
                    .scaledToFit()
                    .frame(width: 50)
                    .foregroundStyle(Color.theme.genreText, Color.theme.red)
                    .padding()
                    .onTapGesture {
                        vm.deleteConfirmationShowing.toggle()
                    }
            }
        }
        .confirmationDialog(
            "Are you sure you'd like to delete from your Watchlist?",
            isPresented: $vm.deleteConfirmationShowing)
        {
            Button("Cancel", role: .cancel) { }
                .buttonStyle(.plain)

            Button("Delete", role: .destructive) {
                Task {
                    for id in vm.selectedRows {
                        try await WatchlistManager.shared.deleteMediaById(mediaId: id)
                        AnalyticsManager.shared.logEvent(name: "MovieTabView_MultiDeleteMedia")
                    }
                    vm.editMode = .inactive
                    homeVM.editMode = .inactive
                }
            }
            .buttonStyle(.plain)
        }
        .scrollIndicators(.hidden)
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
    }
}

extension MovieTabView {
    var watchFilterOptions: some View {
        HStack {
            ForEach(WatchOptions.allCases, id: \.rawValue) { watchOption in
                Text(watchOption.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(width: 110, height: 30)
                    .background {
                        if homeVM.selectedWatchOption == watchOption {
                            Capsule()
                                .fill(Color.theme.red)
                                .matchedGeometryEffect(id: "ACTIVE_OPTION", in: animation)
                        } else {
                            Capsule()
                                .fill(Color.theme.secondary.opacity(0.6))
                        }
                    }
                    .foregroundColor(
                        homeVM.selectedWatchOption == watchOption
                            ? Color.theme.genreText
                            : Color.theme.red.opacity(0.6))
                        .onTapGesture {
                            if homeVM.selectedWatchOption != watchOption {
                                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.75)) {
                                    AnalyticsManager.shared.logEvent(name: "MovieTabView_\(watchOption.rawValue)_Tapped")
                                    homeVM.selectedWatchOption = watchOption
                                    vm.filterText = ""
                                }
                            }
                        }
            }
        }
        .dynamicTypeSize(.medium ... .xLarge)
        .padding(.horizontal)
    }

    var searchResults: [DBMedia] {
        let groupedMedia = homeVM.movieList.filter { !$0.watched }
        if homeVM.selectedWatchOption != .unwatched || !homeVM.genresSelected.isEmpty || homeVM.ratingSelected > 0 {
            var filteredMedia = homeVM.movieList.sorted(by: { !$0.watched && $1.watched })

            /// Watched Filter
            if homeVM.selectedWatchOption == .watched {
                filteredMedia = filteredMedia.filter(\.watched)
            } else if homeVM.selectedWatchOption == .any {
                filteredMedia = filteredMedia.sorted(by: { !$0.watched && $1.watched })
            } else {
                filteredMedia = groupedMedia
            }

            /// Genre Filter
            if !homeVM.genresSelected.isEmpty {
                filteredMedia = filteredMedia.filter { media in
                    guard let genreIDs = media.genreIDs else { return false }
                    var genreFound = false
                    for selectedGenre in homeVM.genresSelected {
                        if genreIDs.contains(selectedGenre.id), genreFound != true {
                            genreFound = true
                        }
                    }
                    return genreFound
                }
            }

            /// Rating Filter
            filteredMedia = filteredMedia.filter { media in
                if let voteAverage = media.voteAverage {
                    return voteAverage >= Double(homeVM.ratingSelected)
                }
                return false
            }

            if !vm.filterText.isEmpty {
                filteredMedia = filteredMedia.filter { $0.title?.lowercased().contains(vm.filterText.lowercased()) ?? false }
            }

            return filteredMedia

        } else if vm.filterText.isEmpty {
            return groupedMedia
        } else {
            return groupedMedia.filter { $0.title?.lowercased().contains(vm.filterText.lowercased()) ?? false }
        }
    }

    var sortedSearchResults: [DBMedia] {
        return searchResults.sorted { media1, media2 in
            switch homeVM.selectedSortingOption {
                case .alphabetical:
                    if let title1 = media1.title, let title2 = media2.title {
                        return title1 < title2
                    } else if let name1 = media1.name, let name2 = media2.name {
                        return name1 < name2
                    } else {
                        return false
                    }
                case .imdbRating:
                    if let voteAverage1 = media1.voteAverage, let voteAverage2 = media2.voteAverage {
                        return voteAverage1 > voteAverage2
                    }
                case .personalRating:
                    return (media1.personalRating ?? 0, media1.voteAverage ?? 0) >
                        (media2.personalRating ?? 0, media2.voteAverage ?? 0)
            }
            return false
        }
    }
}

struct MovieTabView_Previews: PreviewProvider {
    static var previews: some View {
        MovieTabView()
            .environmentObject(dev.homeVM)
    }
}
