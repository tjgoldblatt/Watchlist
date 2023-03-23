//
//  SearchTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI

struct SearchTabView: View {
    @Environment(\.blackbirdDatabase) var database
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    @ObservedObject var vm = SearchTabViewModel()
    
    @State var rowViewManager: RowViewManager
    
    @State var isKeyboardShowing: Bool = false
    @State var bottomPadding: CGFloat = 50.0
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
                    if isKeyboardShowing {
                        bottomPadding = 0.0
                    }
                    isSubmitted = false
                }
                .padding(.bottom, bottomPadding)
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchTabView(rowViewManager: RowViewManager(homeVM: dev.homeVM))
    }
}

extension SearchTabView {
    var header: some View {
        HeaderView(currentTab: .constant(.search), showIcon: true)
            .padding(.horizontal)
    }
    
    var searchBar: some View {
        SearchBarView(searchText: $vm.searchText, currentTab: .constant(Tab.search)) {
            Task {
                await vm.search()
            }
        }
        .onSubmit {
            bottomPadding = 50
        }
        .onChange(of: vm.searchText) { newValue in
            if vm.searchText.isEmpty && !isKeyboardShowing {
                bottomPadding = 50
            }
        }
    }
    
    var searchResults: some View {
        if !vm.isSearching {
            return AnyView(
                List {
                    ForEach(homeVM.results.isEmpty ? vm.results : homeVM.results, id: \.id) { result in
                        if !vm.isSearching {
                            rowViewManager.createRowView(media: result, tab: .search)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                    .toolbar {
                        ToolbarItemGroup {
                            Text("")
                        }
                    }
                    .scrollIndicators(.hidden)
                    .listStyle(.plain)
                    .scrollDismissesKeyboard(.immediately)
                    .scrollDismissesKeyboard(.immediately)
            )
        } else {
            return AnyView(ProgressView())
        }
    }
}
