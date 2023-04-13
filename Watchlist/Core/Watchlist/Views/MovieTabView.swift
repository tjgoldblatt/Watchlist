//
//  MovieTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI
import Blackbird

struct MovieTabView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    
    @StateObject var vm = WatchlistDetailsViewModel()
    
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
    }
    
    // MARK: - Watchlist
    func watchlist(scrollProxy: ScrollViewProxy) -> some View {
        List(selection: $vm.selectedRows) {
            /// Used to scroll to top of list
            EmptyView()
                .id(vm.emptyViewID)
            
            ForEach(sortedSearchResults) { movie in
                RowView(media: movie, currentTab: .movies)
                    .allowsHitTesting(homeVM.editMode == .inactive)
                    .listRowBackground(Color.theme.background)
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
                if homeVM.watchSelected != .unwatched ? !sortedSearchResults.isEmpty : sortedSearchResults.count > 1 {
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
//                            Task {
//                                for watchedSelectedRow in watchedSelectedRows {
//                                    
//                                    if let media = homeVM.decodeData(with: watchedSelectedRow.media) {
//                                        await database?.sendRating(rating: nil, media: media)
//                                        await database?.setWatched(watched: false, media: media)
//                                    }
//                                }
//                                homeVM.editMode = .inactive
//                            }
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
                    //                    database?.deleteMediaByID(id: id)
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

extension MovieTabView {
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
    
    var searchResults: [DBMedia] {
        let groupedMedia = homeVM.movieList.filter({ !$0.watched })
        if homeVM.watchSelected != .unwatched || !homeVM.genresSelected.isEmpty || homeVM.ratingSelected > 0 {
            var filteredMedia = homeVM.movieList.sorted(by: { !$0.watched && $1.watched})
            
            /// Watched Filter
            if homeVM.watchSelected == .watched {
                filteredMedia = filteredMedia.filter({ $0.watched })
            } else if homeVM.watchSelected == .any {
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
                        if genreIDs.contains(selectedGenre.id) && genreFound != true {
                            genreFound = true
                        }
                    }
                    return genreFound
                }
            }
            
            /// Rating Filter
            filteredMedia = filteredMedia.filter { media in
                if let voteAverage = media.voteAverage {
                    return voteAverage > Double(homeVM.ratingSelected)
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

struct MovieTabView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MovieTabView()
                .environmentObject(dev.homeVM)
        }
    }
}
