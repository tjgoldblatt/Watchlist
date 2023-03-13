//
//  HeaderView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI

struct HeaderView: View {
    @Binding var currentTab: Tab
    
    var showIcon: Bool
    
    var body: some View {
        HStack {
            Text(currentTab.rawValue)
                .font(Font.system(size: 36, design: .default))
                .fontWeight(.bold)
          
            if showIcon {
                Image(systemName: currentTab.icon)
                    .foregroundColor(Color.theme.red)
                    .font(.system(.title))
            }
            
            Spacer()
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            HeaderView(currentTab: .constant(.movies), showIcon: true)
            Spacer()
        }
    }
}
//
//class HeaderItem: Hashable, ObservableObject {
//    static func == (lhs: HeaderItem, rhs: HeaderItem) -> Bool {
//        <#code#>
//    }
//
//    @Published var title: String
//    let image: String = ""
//}
