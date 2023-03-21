//
//  CustomTabBarView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI

struct CustomTabBarView: View {
    
    let tabs: [TabBarItem]
    @Binding var selection: TabBarItem
    @Namespace private var namespace
    @State var localSelection: TabBarItem
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State private var tabColor: Color = Color.theme.red
    
    var body: some View {
        tabBarVersion1
            .onChange(of: selection) { newValue in
                withAnimation(.easeInOut) {
                    localSelection = newValue
                }
            }
    }
}

struct CustomTabBarView_Previews: PreviewProvider {
    
    static let tabs: [TabBarItem] = [
        .movie, .tvshow, .search
    ]
    
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBarView(tabs: tabs, selection: .constant(tabs.first!), localSelection: tabs.first!)
        }
    }
}

extension CustomTabBarView {
    
    private func tabView(tab: TabBarItem) -> some View {
        VStack {
            Image(systemName: tab.iconName)
                .font(.title3)
        }
        .foregroundColor(localSelection == tab ? Color.theme.genreText : Color.theme.text.opacity(0.3))
        
        .padding(.vertical, tab == .movie ? 8 : 10)
        .frame(maxWidth: .infinity)
        .background(localSelection == tab ? tabColor.opacity(0.8) : Color.clear)
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .cornerRadius(10)
    }
    
    private var tabBarVersion1: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabView(tab: tab)
                    .onTapGesture {
                        switchToTab(tab: tab)
                        
                        if tab != .search {
                            Task {
                                await homeVM.reloadWatchlist()
                            }
                        }
                        
                    }
            }
        }
        .padding(.horizontal)
        .padding(8)
        .background(Color.theme.background.ignoresSafeArea(edges: .bottom))
    }
    
    
    private func switchToTab(tab: TabBarItem) {
        selection = tab
    }
}

extension CustomTabBarView {
    private func tabView2(tab: TabBarItem) -> some View {
        VStack {
            Image(systemName: tab.iconName)
                .font(.subheadline)
            
            Text(tab.title)
                .font(.system(size: 10, weight: .semibold, design: .default))
        }
        .foregroundColor(localSelection == tab ? tabColor : Color.gray)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                if localSelection == tab {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(tabColor.opacity(0.2))
                        .matchedGeometryEffect(id: "background_rectable", in: namespace)
                }
            }
            
        )
    }
    
    private var tabBarVersion2: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabView2(tab: tab)
                    .onTapGesture {
                        switchToTab(tab: tab)
                    }
            }
        }
        .padding(6)
        .background(Color.theme.genreText.ignoresSafeArea(edges: .bottom))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}
