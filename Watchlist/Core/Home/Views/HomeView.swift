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
    @EnvironmentObject private var homeVM: HomeViewModel
    
    var body: some View {
        if homeVM.isGenresLoaded {
            CustomTabBarContainerView(selection: $homeVM.selectedTab) {
                ShowTabView(rowViewManager: RowViewManager(homeVM: homeVM))
                    .tabBarItem(tab: .home, selection: $homeVM.selectedTab)
//                    .onTapGesture {
//                        Task {
//                            await homeVM.getMoviesFromDatabase()
//                        }
//                    }
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
