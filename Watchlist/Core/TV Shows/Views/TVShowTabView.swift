//
//  TVShowTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/21/23.
//

import SwiftUI

struct TVShowTabView: View {
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
                HeaderView(currentTab: .constant(.tvShows), showIcon: true)
                    .transition(.slide)
            }
            .padding(.horizontal)
            .padding(.top)
            .offset(y: 10)
            
            // MARK: - Search
            SearchBarView(searchText: $vm.filterText, currentTab: .constant(.tvShows)) {
                Task {
                    // TODO: Call to filter through Watchlist
//                    await vm.executeQuery()
                }
            }
            .padding(.bottom)
            
            // MARK: - Watchlist
            List {
                ForEach(homeVM.tvWatchList) { tvShow in
                    rowViewManager.createRowView(tvShow: tvShow, tab: .tvShows)
                }
                .listRowBackground(Color.theme.background)
                .transition(.slide)
            }
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            .scrollDismissesKeyboard(.immediately)
            
            
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

struct TVShowTabView_Previews: PreviewProvider {
    static var previews: some View {
        TVShowTabView(rowViewManager: RowViewManager(homeVM: dev.homeVM))
            .environmentObject(dev.homeVM)
    }
}
