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
                                
                                ForEach(searchResults) { post in
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
                                    if movieList.results.count > 1 {
                                        EditButton()
                                            .foregroundColor(Color.theme.red)
                                    } else {
                                        Text("")
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
                                        homeVM.editMode = .inactive
                                    }
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
        let groupedMedia = homeVM.groupMedia(mediaModel: movieList.results)
        if vm.filterText.isEmpty {
            return groupedMedia
        } else {
            let filteredMedia = groupedMedia.filter { $0.title.lowercased().contains(vm.filterText.lowercased()) }
            return !filteredMedia.isEmpty ? filteredMedia : groupedMedia
        }
    }
}

struct ShowView_Previews: PreviewProvider {
    static var previews: some View {
        MovieTabView(rowViewManager: RowViewManager(homeVM: dev.homeVM))
            .environmentObject(dev.homeVM)
    }
}
