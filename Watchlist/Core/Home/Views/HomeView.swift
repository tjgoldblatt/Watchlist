//
//  HomeView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/8/23.
//

import Blackbird
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    
    @Environment(\.blackbirdDatabase) var database
    @BlackbirdLiveModels({ try await MediaModel.read(from: $0) }) var mediaList
    
    @State var showDebugView = false
    
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
                    
                        .onAppear {
                            Task {
                                if database != nil {
                                    // TODO: Delete this after enough people have transferred their databases
                                    try await homeVM.transferDatabase()
                                } else {
                                    try await WatchlistManager.shared.setTransferred()
                                }
                            }
                        }
                    
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
                        }
                        .tag(Tab.social)
                        .badge(homeVM.pendingFriendRequests)
                }
                .accentColor(Color.theme.red)
                .tint(Color.theme.red)
                .onChange(of: homeVM.selectedTab) { _ in
                    homeVM.genresSelected = []
                    homeVM.ratingSelected = 0
                }
                .onAppear {
                    homeVM.database = database
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
