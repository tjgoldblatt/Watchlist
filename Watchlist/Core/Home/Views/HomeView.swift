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
                        Image(systemName: Tab.movies.icon)
                            .accessibilityIdentifier("MovieTab")
                    }
                    .tag(Tab.movies)
                
                TVShowTabView(rowViewManager: RowViewManager(homeVM: homeVM))
                    .environmentObject(homeVM)
                    .tabItem {
                        Image(systemName: Tab.tvShows.icon)
                            .accessibilityIdentifier("TVShowTab")
                    }
                    .tag(Tab.tvShows)
                
                ExploreTabView(rowViewManager: RowViewManager(homeVM: homeVM))
                    .environmentObject(homeVM)
                    .tabItem {
                        Image(systemName: Tab.explore.icon)
                            .accessibilityIdentifier("ExploreTab")
                    }
                    .tag(Tab.explore)
            }
            .onChange(of: homeVM.selectedTab, perform: { newValue in
                homeVM.getMediaWatchlists()
                homeVM.genresSelected = []
                homeVM.ratingSelected = 0
            })
            .onAppear {
                homeVM.database = database
                homeVM.getMediaWatchlists()
            }
            .tint(Color.theme.red)
            // Solution for iOS 16 apps not showing color properly
            .accentColor(Color.theme.red)
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
