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
                    .tag(Tab.movies)
                
                TVShowTabView(rowViewManager: RowViewManager(homeVM: homeVM))
                    .environmentObject(homeVM)
                    .tabItem {
                        Label("", systemImage: Tab.tvShows.icon)
                    }
                    .tag(Tab.tvShows)
                
                ExploreTabView(rowViewManager: RowViewManager(homeVM: homeVM))
                    .environmentObject(homeVM)
                    .tabItem {
                        Label("", systemImage: Tab.explore.icon)
                    }
                    .tag(Tab.explore)
            }
            .onChange(of: homeVM.selectedTab, perform: { newValue in
                homeVM.getMediaWatchlists()
                homeVM.watchSelected = "Any"
                homeVM.genresSelected = []
                homeVM.ratingSelected = 0
            })
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
