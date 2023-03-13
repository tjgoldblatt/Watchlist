//
//  ShowTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI

struct ShowTabView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    
    @State var vm = ShowDetailsViewModel()
    
    @State var rowViewManager: RowViewManager
    
    @State var isKeyboardShowing: Bool = false
    @State var bottomPadding: CGFloat = 50.0
    @State var isSubmitted: Bool = false
    
    @State var showMovies: Bool = true
    @State var currentTab: Tab = .movies
    @State var otherTab: Tab = .tvShows
    
    @Namespace var animation
    
    var body: some View {
        VStack {
            // MARK: - Header
            HStack {
                HeaderView(currentTab: $currentTab, showIcon: false)
                    .transition(.slide)
                
                SegmentedControl()
                
            }
            .padding(.horizontal)
            .padding(.top)
            .offset(y: 10)
            
            // MARK: - Search
            SearchBarView(searchText: $vm.filterText, currentTab: $currentTab) {
                Task {
                    // TODO: Call to filter through Watchlist
                    //                    await vm.executeQuery()
                }
            }
            .padding(.bottom)
            .onSubmit {
                bottomPadding = 50
                isSubmitted = true
            }
            .onChange(of: vm.filterText) { newValue in
                if vm.filterText.isEmpty && !isKeyboardShowing {
                    bottomPadding = 50
                }
            }
            
            ScrollViewReader { value in
                ScrollView(showsIndicators: false) {
                    if showMovies {
                        VStack {
                            ForEach(homeVM.movieWatchList) { movie in
                                rowViewManager.createRowView(movie: movie)
                            }
                        }
                        .transition(.slide)
                    }
                    
                    
                    if !showMovies {
                        VStack {
                            ForEach(homeVM.tvWatchList) { tvShow in
                                rowViewManager.createRowView(tvShow: tvShow)
                            }
                        }
                        .transition(.slide)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
                .onAppear {
                    if showMovies {
                        value.scrollTo(homeVM.movieWatchList.first)
                    } else {
                        value.scrollTo(homeVM.tvWatchList.first)
                    }
                }
                .onChange(of: showMovies) { _ in
                    // TODO: eventually this will be scrollTo(tvShows/Movies).first
                    if showMovies {
                        value.scrollTo(homeVM.movieWatchList.first)
                    } else {
                        value.scrollTo(homeVM.tvWatchList.first)
                    }
                }
            }
            
            /*
             // MARK: - Watchlist
             ScrollView(showsIndicators: false) {
             LazyVStack {
             if isSubmitted {
             ForEach(vm.results, id: \.id) { result in
             if !vm.isSearching {
             RowViewManager.createRowView(media: result)
             }
             }
             }
             }
             }
             .overlay {
             if vm.isSearching {
             ProgressView()
             }
             }
             */
            Spacer()
        }
        .onReceive(keyboardPublisher) { value in
            isKeyboardShowing = value
            if isKeyboardShowing {
                bottomPadding = 0.0
            }
            isSubmitted = false
        }
        .padding(.bottom, bottomPadding)
    }
    
    /// Custom Segmented Control
    @ViewBuilder
    func SegmentedControl() -> some View {
        HStack {
            TabButton(tab: .movies, animation: animation, currentTab: $currentTab, showMovies: $showMovies)
            TabButton(tab: .tvShows, animation: animation, currentTab: $currentTab, showMovies: $showMovies)
        }
        .background(Color.theme.text.opacity(0.1), in: Capsule())
        .padding(.horizontal)
    }
}

struct ShowView_Previews: PreviewProvider {
    static var previews: some View {
        ShowTabView(rowViewManager: RowViewManager(homeVM: dev.homeVM))
            .environmentObject(dev.homeVM)
    }
}

struct TabButton: View {
    var tab: Tab
    var animation: Namespace.ID
    @Binding var currentTab: Tab
    @Binding var showMovies: Bool
    var body: some View {
        Button {
            withAnimation(.spring()) {
                currentTab = tab
            }
            if tab == .movies {
                showMovies = true
            } else {
                showMovies = false
            }
        } label: {
            Image(systemName: tab.icon)
                .fontWeight(.bold)
                .foregroundColor(currentTab == tab ? Color.theme.genreText : Color.theme.text.opacity(0.3))
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        if currentTab == tab {
                            Capsule()
                                .fill(Color.theme.red)
                                .matchedGeometryEffect(id: "TAB", in: animation)
                        }
                    }
                )
        }
    }
}
