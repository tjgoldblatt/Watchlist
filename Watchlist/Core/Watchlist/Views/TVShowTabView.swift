//
//  TVShowTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/21/23.
//

import FirebaseAnalyticsSwift
import SwiftUI

struct TVShowTabView: View {
    @EnvironmentObject private var homeVM: HomeViewModel

    @StateObject var vm = WatchlistDetailsViewModel()

    @Namespace private var animation

    var watchedSelectedRows: [DBMedia] {
        return vm.getWatchedSelectedRows(mediaList: homeVM.tvList)
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

                        if !homeVM.tvList.isEmpty {
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
        .analyticsScreen(name: "TVTabView")
    }
}

extension TVShowTabView {
    // MARK: - Header

    var header: some View {
        HStack {
            HeaderView(currentTab: .constant(.tvShows), showIcon: true)
                .transition(.slide)
        }
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
            ForEach(sortedSearchResults) { tvShow in
                RowView(media: tvShow)
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
                    Button {
                        if vm.editMode == .active {
                            withAnimation(.default) {
                                vm.editMode = .inactive
                                homeVM.editMode = .inactive
                            }
                        } else {
                            withAnimation(.default) {
                                vm.editMode = .active
                                homeVM.editMode = .active
                            }
                        }
                    } label: {
                        if vm.editMode == .active {
                            Image(systemName: "checkmark.circle.fill")
                                .background(
                                    RoundedRectangle(cornerRadius: 10).fill(.clear)
                                        .matchedGeometryEffect(id: "edit", in: animation)
                                )
                                .font(.headline)
                                .foregroundColor(Color.theme.red)

                        } else {
                            Image(systemName: "checklist")
                                .background(
                                    RoundedRectangle(cornerRadius: 10).fill(.clear)
                                        .matchedGeometryEffect(id: "edit", in: animation)
                                )
                                .font(.headline)
                                .foregroundColor(Color.theme.red)
                        }
                    }
                }
            }

            if !watchedSelectedRows.isEmpty, vm.editMode == .active {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        AnalyticsManager.shared.logEvent(name: "MovieTabView_ResetMedia")
                        Task {
                            for watchedSelectedRow in watchedSelectedRows {
                                try await WatchlistManager.shared.resetMedia(media: watchedSelectedRow)
                            }
                            withAnimation(.default) {
                                vm.selectedRows = []
                                vm.editMode = .inactive
                                homeVM.editMode = .inactive
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise.circle")
                            .font(.headline)
                            .foregroundColor(Color.theme.red)
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
            isPresented: $vm.deleteConfirmationShowing
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    for id in vm.selectedRows {
                        try await WatchlistManager.shared.deleteMediaById(mediaId: id)
                        AnalyticsManager.shared.logEvent(name: "TVTabView_MultiDeleteMedia")
                    }
                    vm.editMode = .inactive
                    homeVM.editMode = .inactive
                }
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
    }
}

extension TVShowTabView {
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
                            : Color.theme.red.opacity(0.6)
                    )
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
        let groupedMedia = homeVM.tvList.filter { !$0.watched }
        if homeVM.selectedWatchOption != .unwatched || !homeVM.genresSelected.isEmpty || homeVM.ratingSelected > 0 || homeVM
            .filterByCurrentlyWatching
        {
            var filteredMedia = homeVM.tvList.sorted(by: { !$0.watched && $1.watched })

            // MARK: - Watched Filter

            if homeVM.selectedWatchOption == .watched {
                filteredMedia = filteredMedia.filter(\.watched)
            } else if homeVM.selectedWatchOption == .any {
                filteredMedia = filteredMedia.sorted(by: { !$0.watched && $1.watched })
            } else {
                filteredMedia = groupedMedia
            }

            // MARK: - Currently Watching

            if homeVM.filterByCurrentlyWatching {
                filteredMedia = filteredMedia.filter(\.currentlyWatching)
            }

            // MARK: - Genre Filter

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

            // MARK: - Rating Filter

            filteredMedia = filteredMedia.filter { media in
                if let voteAverage = media.voteAverage {
                    return voteAverage >= Double(homeVM.ratingSelected)
                }
                return false
            }

            if !vm.filterText.isEmpty {
                filteredMedia = filteredMedia.filter { $0.name?.lowercased().contains(vm.filterText.lowercased()) ?? false }
            }

            return filteredMedia

        } else if vm.filterText.isEmpty {
            return groupedMedia
        } else {
            return groupedMedia.filter { $0.name?.lowercased().contains(vm.filterText.lowercased()) ?? false }
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

struct EmptyListView: View {
    @EnvironmentObject private var homeVM: HomeViewModel

    var body: some View {
        VStack {
            Spacer()
            Image(systemName: homeVM.selectedTab.icon)
                .resizable()
                .foregroundColor(Color.theme.secondary)
                .scaledToFit()
                .frame(maxHeight: 150)
            Text("Looks like your Watchlist is Empty!")
                .font(.headline)
                .foregroundColor(Color.theme.secondary)
                .padding()
            Button {
                homeVM.selectedTab = .explore
            } label: {
                Text("Add \(homeVM.selectedTab == .movies ? "Movies" : "TV Shows")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.genreText)
                    .padding(.vertical, 13)
                    .padding(.horizontal, 25)
                    .background(Color.theme.red)
                    .cornerRadius(10)
            }
            Spacer()
        }
    }
}

struct TVShowTabView_Previews: PreviewProvider {
    static var previews: some View {
        TVShowTabView()
            .environmentObject(dev.homeVM)
    }
}
