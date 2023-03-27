//
//  ExploreTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI
import Blackbird

struct ExploreTabView: View {
    @Environment(\.blackbirdDatabase) var database
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    var vm: SearchTabViewModel {
        SearchTabViewModel(homeVM: homeVM)
    }
    
    @State var rowViewManager: RowViewManager
    
    @State var isKeyboardShowing: Bool = false
    @State var isSubmitted: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Background
                Color.theme.background.ignoresSafeArea()
                
                VStack {
                    header
                    
                    searchBar
                    
                    searchResults
                    
                    Spacer()
                }
                .onReceive(keyboardPublisher) { value in
                    isKeyboardShowing = value
                    isSubmitted = false
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreTabView(rowViewManager: RowViewManager(homeVM: dev.homeVM))
    }
}

extension ExploreTabView {
    var header: some View {
        HeaderView(currentTab: .constant(.explore), showIcon: true)
            .padding(.horizontal)
    }
    
    var searchBar: some View {
        SearchBarView(searchText: $homeVM.searchText, currentTab: .constant(Tab.explore), genres: ["Action", "Science Fiction"]) {
            Task {
                await vm.search()
            }
        }
        .padding(.bottom)
    }
    
    var searchResults: some View {
        if !vm.isSearching {
            return AnyView(
                List {
                    ForEach(homeVM.results, id: \.id) { result in
                        rowViewManager.createRowView(media: result, tab: .explore)
                    }
                    .listRowBackground(Color.clear)
                }
                    .toolbar {
                        Text("")
                    }
                    .scrollIndicators(.hidden)
                    .listStyle(.plain)
                    .scrollDismissesKeyboard(.immediately)
            )
        } else {
            return AnyView(ProgressView())
        }
    }
}
