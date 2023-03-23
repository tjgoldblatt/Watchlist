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
    
    @BlackbirdLiveModels({ try await MediaModel.read(from: $0, matching: \.$mediaType == "movie", orderBy: .ascending(\.$title)) }) var movieList
    
    @EnvironmentObject private var homeVM: HomeViewModel
    
    @ObservedObject var vm = ShowDetailsViewModel()
    
    @State var rowViewManager: RowViewManager
    
    @State var isKeyboardShowing: Bool = false
    @State var bottomPadding: CGFloat = 50.0
    @State var isSubmitted: Bool = false
    
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
                    //                    await vm.search()
                }
            }
            .padding(.bottom)
            
            // MARK: - Watchlist
            if movieList.didLoad {
                List {
                    ForEach(homeVM.groupMedia(mediaModel: movieList.results)) { post in
                        if let movie = homeVM.decodeData(with: post.media) {
                            rowViewManager.createRowView(movie: movie, tab: .movies)
                        }
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
