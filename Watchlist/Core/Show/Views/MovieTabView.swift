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
    
    @BlackbirdLiveModels({ try await Post.read(from: $0, matching: \.$mediaType == "movie") }) var movieList
    
    @EnvironmentObject private var homeVM: HomeViewModel
    
    @ObservedObject var vm = ShowDetailsViewModel()
    
    @State var rowViewManager: RowViewManager
    
    @State var isKeyboardShowing: Bool = false
    @State var bottomPadding: CGFloat = 50.0
    @State var isSubmitted: Bool = false
    
    @State var count: Int64 = 0
    
    @Namespace var animation
    
    var body: some View {
        VStack {
            // MARK: - Header
            HStack {
                HeaderView(currentTab: .constant(.movies), showIcon: true)
                    .transition(.slide)
            }
            .padding(.horizontal)
            .padding(.top)
            .offset(y: 10)
            
            // MARK: - Search
            SearchBarView(searchText: $vm.filterText, currentTab: .constant(.movies)) {
                Task {
                    // TODO: Call to filter through Watchlist
                    //                    await vm.executeQuery()
                }
            }
            .padding(.bottom)
            
//            Button {
//                WatchlistDataStore.shared.insert(id: count)
//                count += 1
//            } label: {
//                Text("Press Me")
//            }
//            .padding(.vertical)
//
//            Button {
//                WatchlistDataStore.shared.getAllTasks()
//            } label: {
//                Text("Shared")
//            }

            
            // MARK: - Watchlist
            if movieList.didLoad {
                List {
                    ForEach(movieList.results) { post in
//                        if let movie = homeVM.decodeData(with: post.media) {
//                            rowViewManager.createRowView(movie: movie, tab: .movies)
//                        }
                        Text(post.mediaType)
                    }
                    .listRowBackground(Color.theme.background)
                    .transition(.slide)
                }
                .scrollIndicators(.hidden)
                .listStyle(.plain)
                .scrollDismissesKeyboard(.immediately)
            } else {
                ProgressView()
            }
            
            
            Spacer()
        }
        .onReceive(keyboardPublisher) { value in
            isKeyboardShowing = value
            if isKeyboardShowing {
                bottomPadding = 0.0
            } else {
                bottomPadding = 50
            }
            isSubmitted = false
        }
        .padding(.bottom, bottomPadding)
    }
}

struct ShowView_Previews: PreviewProvider {
    static var previews: some View {
        MovieTabView(rowViewManager: RowViewManager(homeVM: dev.homeVM))
            .environmentObject(dev.homeVM)
    }
}
