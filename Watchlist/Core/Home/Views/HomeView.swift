//
//  HomeView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/8/23.
//

import SwiftUI
import TMDb
import Combine

struct HomeView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    
    var body: some View {
        if homeVM.isGenresLoaded {
            CustomTabBarContainerView(selection: $homeVM.selectedTab) {
                ShowTabView(rowViewManager: RowViewManager(homeVM: homeVM))
                    .tabBarItem(tab: .home, selection: $homeVM.selectedTab)
                
                SearchTabView(rowViewManager: RowViewManager(homeVM: homeVM))
                    .tabBarItem(tab: .search, selection: $homeVM.selectedTab)
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
//
//extension HomeView {
//    private var defaultTabView: some View {
//        TabView(selection: $homeVM.selectedTab) {
//
//            ShowTabView()
//                .tabItem {
//                    Label("", systemImage: "film.stack")
//                }
//
//            SearchTabView(rowViewManager: RowViewManager(homeVM: homeVM))
//                .tabItem {
//                    Label("", systemImage: "magnifyingglass")
//                }
//        }
//    }
//}
