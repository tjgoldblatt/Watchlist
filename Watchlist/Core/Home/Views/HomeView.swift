//
//  HomeView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/8/23.
//

import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    
    var body: some View {
        if homeVM.isGenresLoaded {
            CustomTabBarContainerView(selection: $homeVM.selectedTab) {
                MovieTabView(rowViewManager: RowViewManager(homeVM: homeVM))
                    .tabBarItem(tab: .movie, selection: $homeVM.selectedTab)
                    .environmentObject(homeVM)
                
                TVShowTabView(rowViewManager: RowViewManager(homeVM: homeVM))
                    .tabBarItem(tab: .tvshow, selection: $homeVM.selectedTab)
                    .environmentObject(homeVM)
                
                SearchTabView(rowViewManager: RowViewManager(homeVM: homeVM))
                    .tabBarItem(tab: .search, selection: $homeVM.selectedTab)
                    .environmentObject(homeVM)
            }
        } else {
            ProgressView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        HomeView()
    }
}
