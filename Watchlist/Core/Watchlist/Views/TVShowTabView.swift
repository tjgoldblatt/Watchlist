//
//  TVShowTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/21/23.
//

import SwiftUI
import Blackbird

struct TVShowTabView: View {
    @Environment(\.blackbirdDatabase) var database
    
    @BlackbirdLiveModels({ try await MediaModel.read(from: $0, matching: \.$mediaType == MediaType.tv.rawValue, orderBy: .ascending(\.$title)) }) var tvList
    
    @EnvironmentObject private var homeVM: HomeViewModel
    
    @StateObject var vm = WatchlistDetailsViewModel()
    
    @State var rowViewManager: RowViewManager
    
    var watchedSelectedRows: [MediaModel] {
        return vm.getWatchedSelectedRows(mediaModelArray: tvList.results)
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
                        
                        if tvList.didLoad {
                            watchFilterOptions
                            
                            if !sortedSearchResults.isEmpty {
                                watchlist(scrollProxy: proxy)
                            } else {
                                EmptyListView()
                            }
                        } else {
                            ProgressView()
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
    }
    
    // MARK: - Watchlist
    func watchlist(scrollProxy: ScrollViewProxy) -> some View {
        List(selection: $vm.selectedRows) {
            /// Used to scroll to top of list
            EmptyView()
                .id(vm.emptyViewID)
            
            ForEach(sortedSearchResults) { post in
                if let tvShow = homeVM.decodeData(with: post.media) {
                    rowViewManager.createRowView(tvShow: tvShow, tab: .tvShows)
                        .allowsHitTesting(homeVM.editMode == .inactive)
                        .listRowBackground(Color.theme.background)
                }
            }
            .onChange(of: homeVM.watchSelected) { _ in
                if sortedSearchResults.count > 3 {
                    scrollProxy.scrollTo(vm.emptyViewID)
                }
            }
            .listRowBackground(Color.theme.background)
            .transition(.slide)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if !sortedSearchResults.isEmpty {
                    EditButton()
                        .foregroundColor(Color.theme.red)
                        .padding()
                        .contentShape(Rectangle())
                        .buttonStyle(.plain)
                }
            }
            
            if !watchedSelectedRows.isEmpty && homeVM.editMode == .active {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Reset")
                        .font(.body)
                        .foregroundColor(Color.theme.red)
                        .padding()
                        .onTapGesture {
                            Task {
                                for watchedSelectedRow in watchedSelectedRows {
                                    if let media = homeVM.decodeData(with: watchedSelectedRow.media) {
                                        await database?.sendRating(rating: nil, media: media)
                                        await database?.setWatched(watched: false, media: media)
                                    }
                                }
                                homeVM.editMode = .inactive
                            }
                        }
                }
            }
        }
        .background(.clear)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, $homeVM.editMode)
        .overlay(alignment: .bottomTrailing) {
            if !vm.selectedRows.isEmpty && homeVM.editMode == .active {
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
        .alert("Are you sure you'd like to delete from your Watchlist?", isPresented: $vm.deleteConfirmationShowing) {
            Button("Delete", role: .destructive) {
                for id in vm.selectedRows {
                    database?.deleteMediaByID(id: id)
                }
                homeVM.editMode = .inactive
            }
            .buttonStyle(.plain)
            
            Button("Cancel", role: .cancel) {}
                .buttonStyle(.plain)
        }
        .scrollIndicators(.hidden)
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
    }
}


extension TVShowTabView {
    var watchFilterOptions: some View {
        HStack {
            ForEach(WatchOptions.allCases, id: \.rawValue) { watchOption in
                Text(watchOption.rawValue)
                    .foregroundColor(homeVM.watchSelected == watchOption ? Color.theme.genreText : Color.theme.red.opacity(0.6))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(width: 110, height: 30)
                    .contentShape(Capsule())
                    .background {
                        Capsule()
                            .foregroundColor(homeVM.watchSelected == watchOption ? Color.theme.red : Color.theme.secondary.opacity(0.6))
                    }
                    .onTapGesture {
                        homeVM.hapticFeedback.impactOccurred()
                        if homeVM.watchSelected != watchOption {
                            homeVM.watchSelected = watchOption
                            vm.filterText = ""
                        }
                    }
            }
        }
        .padding(.horizontal)
    }
    
    var searchResults: [MediaModel] {
        let groupedMedia = tvList.results.filter({ !$0.watched })
        if homeVM.watchSelected != .unwatched || !homeVM.genresSelected.isEmpty || homeVM.ratingSelected > 0 {
            var filteredMedia = tvList.results.sorted(by: { !$0.watched && $1.watched})
            
            /// Watched Filter
            if homeVM.watchSelected == .watched {
                filteredMedia = filteredMedia.filter({ $0.watched })
            } else if homeVM.watchSelected == .any {
                filteredMedia = filteredMedia.sorted(by: { !$0.watched && $1.watched })
            }
            
            /// Genre Filter
            if !homeVM.genresSelected.isEmpty {
                filteredMedia = filteredMedia.filter { media in
                    guard let genreIDs = media.genreIDs else { return false }
                    var genreFound = false
                    for selectedGenre in homeVM.genresSelected {
                        if genreIDs.contains("\(selectedGenre.id)") && genreFound != true {
                            genreFound = true
                        }
                    }
                    return genreFound
                }
            }
            
            /// Rating Filter
            filteredMedia = filteredMedia.filter { mediaModel in
                if let media = homeVM.decodeData(with: mediaModel.media) {
                    if let voteAverage = media.voteAverage {
                        return voteAverage > Double(homeVM.ratingSelected)
                    }
                }
                return false
            }
            
            if !vm.filterText.isEmpty {
                filteredMedia = filteredMedia.filter { $0.title.lowercased().contains(vm.filterText.lowercased()) }
            }
            
            return filteredMedia
            
        } else if vm.filterText.isEmpty {
            return groupedMedia
        } else {
            return groupedMedia.filter { $0.title.lowercased().contains(vm.filterText.lowercased()) }
        }
    }
    
    var sortedSearchResults: [MediaModel] {
        return searchResults.sorted { MM1, MM2 in
            if let media1 = homeVM.decodeData(with: MM1.media), let media2 = homeVM.decodeData(with: MM2.media) {
                if homeVM.sortingSelected == .highToLow {
                    if let voteAverage1 = media1.voteAverage, let voteAverage2 = media2.voteAverage {
                        return voteAverage1 > voteAverage2
                    }
                } else if homeVM.sortingSelected == .lowToHigh {
                    if let voteAverage1 = media1.voteAverage, let voteAverage2 = media2.voteAverage {
                        return voteAverage1 < voteAverage2
                    }
                }
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
        TVShowTabView(rowViewManager: RowViewManager(homeVM: dev.homeVM))
            .environmentObject(dev.homeVM)
    }
}
