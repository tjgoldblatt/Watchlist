//
//  ContentView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/8/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Text("Text color")
                    .foregroundColor(Color.theme.text)

                Text("Secondary color")
                    .foregroundColor(Color.theme.secondary)

                Text("Red color")
                    .foregroundColor(Color.theme.red)
            }
            .font(.headline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
