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
    
    @Environment(\.blackbirdDatabase) var database
    
    var body: some View {
        if homeVM.isGenresLoaded {
            TabView(selection: $homeVM.selectedTab) {
                MovieTabView(rowViewManager: RowViewManager(homeVM: homeVM))
                    .environmentObject(homeVM)
                    .tabItem {
                        Label("", systemImage: Tab.movies.icon)
                    }
                    .tag(TabBarItem.movie)
                
                TVShowTabView(rowViewManager: RowViewManager(homeVM: homeVM))
                    .environmentObject(homeVM)
                    .tabItem {
                        Label("", systemImage: Tab.tvShows.icon)
                    }
                    .tag(TabBarItem.tvshow)
                
                ExploreTabView(rowViewManager: RowViewManager(homeVM: homeVM))
                    .environmentObject(homeVM)
                    .tabItem {
                        Label("", systemImage: Tab.explore.icon)
                    }
                    .tag(TabBarItem.explore)
            }
            .onAppear {
                homeVM.database = database
                homeVM.getMediaWatchlists()
            }
            .tint(Color.theme.red)
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
