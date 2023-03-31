//
//  MovieTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI
import Blackbird

struct MovieTabView: View {
    @Environment(\.blackbirdDatabase) var database
    
    @BlackbirdLiveModels({ try await MediaModel.read(from: $0, matching: \.$mediaType == MediaType.movie.rawValue, orderBy: .ascending(\.$title)) }) var movieList
    
    @EnvironmentObject private var homeVM: HomeViewModel
    
    @ObservedObject var vm = ShowDetailsViewModel()
    
    @State var rowViewManager: RowViewManager
    
    @State var isKeyboardShowing: Bool = false
    
    @State var isSubmitted: Bool = false
    
    @State var selectedRows = Set<Int>()
    
    @State var deleteConfirmationShowing: Bool = false
    
    @Namespace var animation
    
    private static let topID = "HeaderView"
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                Color.theme.background.ignoresSafeArea()
                
                ScrollViewReader { value in
                    VStack {
                        // MARK: - Header
                        HeaderView(currentTab: .constant(.movies), showIcon: true)
                            .transition(.slide)
                            .padding(.horizontal)
                        
                        // MARK: - Search
                        SearchBarView(searchText: $vm.filterText, genres: ["Sci Fi", "History"]) {
                            Task {
                                if(!searchResults.isEmpty) {
                                    value.scrollTo(Self.topID)
                                }
                            }
                        }
                        .padding(.bottom)
                        
                        // MARK: - Watchlist
                        if movieList.didLoad {
                            List(selection: $selectedRows) {
                                /// Used to scroll to top of list
                                EmptyView()
                                    .id(Self.topID)
                                
                                ForEach(sortedSearchResults) { post in
                                    if let movie = homeVM.decodeData(with: post.media) {
                                        rowViewManager.createRowView(movie: movie, tab: .movies)
                                            .allowsHitTesting(homeVM.editMode == .inactive)
                                    }
                                }
                                .listRowBackground(Color.theme.background)
                                .transition(.slide)
                            }
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    if sortedSearchResults.count > 1 {
                                        EditButton()
                                            .foregroundColor(Color.theme.red)
                                            .padding()
                                            .contentShape(Rectangle())
                                    } else {
                                        Text("")
                                    }
                                }
                                
                                if !selectedRows.isEmpty {
                                    ToolbarItem(placement: .navigationBarLeading) {
                                        Text("Reset")
                                            .font(.body)
                                            .foregroundColor(Color.theme.red)
                                            .padding()
                                            .onTapGesture {
                                                Task {
                                                    for id in selectedRows {
                                                        for mediaModel in movieList.results.filter({ $0.id == id }) {
                                                            if let media = homeVM.decodeData(with: mediaModel.media) {
                                                                await database?.sendRating(rating: nil, media: media)
                                                                await database?.setWatched(watched: false, media: media)
                                                            }
                                                        }
                                                    }
                                                    homeVM.editMode = .inactive
                                                }
                                            }
                                    }
                                }
                            }
                            .environment(\.editMode, $homeVM.editMode)
                            .overlay(alignment: .bottomTrailing) {
                                if !selectedRows.isEmpty && homeVM.editMode == .active {
                                    Image(systemName: "trash.circle.fill")
                                        .resizable()
                                        .fontWeight(.bold)
                                        .scaledToFit()
                                        .frame(width: 50)
                                        .foregroundStyle(Color.theme.genreText, Color.theme.red)
                                        .shadow(color: Color.black.opacity(0.2), radius: 10)
                                        .padding()
                                        .onTapGesture {
                                            deleteConfirmationShowing.toggle()
                                        }
                                }
                            }
                            .alert("Are you sure you'd like to delete from your Watchlist?", isPresented: $deleteConfirmationShowing) {
                                Button("Delete", role: .destructive) {
                                    for id in selectedRows {
                                        database?.deleteMediaByID(id: id)
                                    }
                                    homeVM.editMode = .inactive
                                }
                                
                                Button("Cancel", role: .cancel) {}
                            }
                            .scrollIndicators(.hidden)
                            .listStyle(.plain)
                            .scrollDismissesKeyboard(.immediately)
                        } else {
                            ProgressView()
                        }
                        
                        Spacer()
                    }
                }
                .onReceive(keyboardPublisher) { value in
                    isKeyboardShowing = value
                    isSubmitted = false
                }
            }
        }
    }
    
    var searchResults: [MediaModel] {
        let groupedMedia = homeVM.groupMedia(mediaModel: movieList.results).filter({ !$0.watched })
        if homeVM.watchSelected != "Unwatched" || !homeVM.genresSelected.isEmpty || homeVM.ratingSelected > 0 {
            var filteredMedia = homeVM.groupMedia(mediaModel: movieList.results).sorted(by: { !$0.watched && $1.watched })
            
            /// Watched Filter
            if homeVM.watchSelected == "Watched" {
                filteredMedia = filteredMedia.filter({ $0.watched })
            }
            
            /// Genre Filter
            if !homeVM.genresSelected.isEmpty {
                filteredMedia = filteredMedia.filter { media in
                    guard let genreIDs = media.genreIDs else { return false }
                    for selectedGenre in homeVM.genresSelected {
                        return genreIDs.contains("\(selectedGenre.id)")
                    }
                    return false
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
            
            return filteredMedia
            
        } else if vm.filterText.isEmpty {
            return groupedMedia
        } else {
            let filteredMedia = groupedMedia.filter { $0.title.lowercased().contains(vm.filterText.lowercased()) }
            return !filteredMedia.isEmpty ? filteredMedia : groupedMedia
        }
    }
    
    var sortedSearchResults: [MediaModel] {
        return searchResults.sorted { MM1, MM2 in
            if let media1 = homeVM.decodeData(with: MM1.media), let media2 = homeVM.decodeData(with: MM2.media) {
                if homeVM.sortingSelected == "Rating (High to Low)" {
                    if let voteAverage1 = media1.voteAverage, let voteAverage2 = media2.voteAverage {
                        return voteAverage1 > voteAverage2
                    }
                } else if homeVM.sortingSelected == "Rating (Low to High)" {
                    if let voteAverage1 = media1.voteAverage, let voteAverage2 = media2.voteAverage {
                        return voteAverage1 < voteAverage2
                    }
                }
            }
            return false
        }
    }
}

struct ShowView_Previews: PreviewProvider {
    static var previews: some View {
        MovieTabView(rowViewManager: RowViewManager(homeVM: dev.homeVM))
            .environmentObject(dev.homeVM)
    }
}
