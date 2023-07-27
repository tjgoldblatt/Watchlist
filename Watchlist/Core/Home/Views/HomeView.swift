//
//  HomeView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/8/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var homeVM: HomeViewModel

    @State var showDebugView = false
    @State private var currentTab: Tab = .movies

    var body: some View {
        if homeVM.isGenresLoaded {
            ZStack {
                TabView(selection: $homeVM.selectedTab) {
                    MovieTabView()
                        .environmentObject(homeVM)
                        .tabItem {
                            Image(systemName: Tab.movies.icon)
                                .accessibilityIdentifier("MovieTab")
                        }
                        .tag(Tab.movies)

                    TVShowTabView()
                        .environmentObject(homeVM)
                        .tabItem {
                            Image(systemName: Tab.tvShows.icon)
                                .accessibilityIdentifier("TVShowTab")
                        }
                        .tag(Tab.tvShows)

                    ExploreTabView(homeVM: homeVM)
                        .environmentObject(homeVM)
                        .tabItem {
                            Image(systemName: Tab.explore.icon)
                                .accessibilityIdentifier("ExploreTab")
                        }
                        .tag(Tab.explore)

                    SocialTabView()
                        .environmentObject(homeVM)
                        .tabItem {
                            Image(systemName: Tab.social.icon)
                                .accessibilityIdentifier("SocialTab")
                        }
                        .tag(Tab.social)
                        .badge(homeVM.pendingFriendRequests)
                }
                .onAppear {
                    // correct the transparency bug for Tab bars
                    UITabBar.appearance().shadowImage = UIImage()
                    UITabBar.appearance().backgroundImage = UIImage()
                    UITabBar.appearance().isTranslucent = true
                    UITabBar.appearance().backgroundColor = UIColor(Color.theme.background)
                }
                .preferredColorScheme(.dark)
                .accentColor(Color.theme.red)
                .tint(Color.theme.red)
                .onChange(of: homeVM.selectedTab) { updatedTab in
                    homeVM.hapticFeedback.impactOccurred()
                    withAnimation(.easeIn) {
                        currentTab = updatedTab
                        homeVM.genresSelected = []
                        homeVM.ratingSelected = 0
                        homeVM.filterByCurrentlyWatching = false
                    }
                }
                .onReceive(homeVM.$selectedTab) { selectedTab in
                    if currentTab == .explore, selectedTab == .explore {
                        homeVM.searchText = ""
                        homeVM.results = []
                    }
                }

                VStack {
                    Spacer()
                    if homeVM.editMode == .active {
                        Rectangle()
                            .fill(Color.white.opacity(0.001))
                            .frame(width: .infinity, height: 50)
                    }
                }
            }
            .dynamicTypeSize(.medium ... .xLarge)
            .onShake {
                if ApplicationHelper.isDebug {
                    showDebugView.toggle()
                }
            }
            .sheet(isPresented: $showDebugView) {
                DebugView()
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
