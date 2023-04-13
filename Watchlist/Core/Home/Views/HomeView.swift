//
//  HomeView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/8/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    
    var body: some View {
        if homeVM.isGenresLoaded {
            TabView(selection: $homeVM.selectedTab) {
                MovieTabView()
                    .environmentObject(homeVM)
                    .tabItem {
                        Image(systemName: Tab.movies.icon)
                            .accessibilityIdentifier("MovieTab")
                    }
                    .tag(Tab.movies)
                
                    .onAppear {
                        Task {
                            try await homeVM.getWatchlists()
                        }
                        
                        // TODO: Delete this after enough people have transferred their databases
                        homeVM.transferDatabase()
                    }
                
                TVShowTabView()
                    .environmentObject(homeVM)
                    .tabItem {
                        Image(systemName: Tab.tvShows.icon)
                            .accessibilityIdentifier("TVShowTab")
                    }
                    .tag(Tab.tvShows)
                
                ExploreTabView()
                    .environmentObject(homeVM)
                    .tabItem {
                        Image(systemName: Tab.explore.icon)
                            .accessibilityIdentifier("ExploreTab")
                    }
                    .tag(Tab.explore)
                
                SocialView()
                    .environmentObject(homeVM)
                    .tabItem {
                        Image(systemName: Tab.social.icon)
                    }
                    .tag(Tab.social)
            }
            .accentColor(Color.theme.red)
            .tint(Color.theme.red)
            .onChange(of: homeVM.selectedTab) { newValue in
                Task {
                    try await homeVM.getWatchlists()
                }
                homeVM.genresSelected = []
                homeVM.ratingSelected = 0
            }
            .task {
                try? await homeVM.getWatchlists()
            }
        } else {
            ProgressView()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    
    static var previews: some View {
        HomeView()
            .environmentObject(dev.homeVM)
    }
}
