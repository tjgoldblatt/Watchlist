//
//  SearchTabView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI

struct SearchTabView: View {
    
    @ObservedObject var vm = SearchDetailsViewModel()

    @State var rowViewManager: RowViewManager
    
    @State var isKeyboardShowing: Bool = false
    @State var bottomPadding: CGFloat = 50.0
    @State var isSubmitted: Bool = false
    
    var body: some View {
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

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchTabView(rowViewManager: RowViewManager(homeVM: dev.homeVM))
    }
}

extension SearchTabView {
    var header: some View {
        HeaderView(currentTab: .constant(.search), showIcon: true)
            .padding(.horizontal)
            .padding(.top)
    }
    
    var searchBar: some View {
        SearchBarView(searchText: $vm.searchText, currentTab: .constant(Tab.search)) {
            Task {
                await vm.executeQuery()
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
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(vm.results, id: \.id) { result in
                    if !vm.isSearching {
                        rowViewManager.createRowView(media: result)
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .overlay {
            if vm.isSearching {
                ProgressView()
            }
        }
    }
}
