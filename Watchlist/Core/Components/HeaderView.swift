//
//  HeaderView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI

struct HeaderView: View {
    @Binding var currentTab: Tab
    @State var headerString = ""
    
    var showIcon: Bool
    
    var body: some View {
        HStack {
            Text(headerString.isEmpty ? currentTab.rawValue : headerString)
                .foregroundColor(Color.theme.text)
                .font(.largeTitle)
                .fontWeight(.bold)
                .dynamicTypeSize(.large...)
          
            if showIcon {
                Image(systemName: currentTab.icon)
                    .foregroundColor(Color.theme.red)
                    .font(.system(.title))
                    .fontWeight(.semibold)
                    .dynamicTypeSize(...DynamicTypeSize.xLarge)
            }
            
            Spacer()
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HeaderView(currentTab: .constant(.tvShows), showIcon: true)
            Spacer()
        }
    }
}
