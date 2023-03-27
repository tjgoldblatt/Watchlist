//
//  FilterModalView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/25/23.
//

import SwiftUI
import Blackbird

struct FilterModalView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var selectedTab: Tab
    
    @ObservedObject var vm = FilterModalViewModel()
    
    
//    @Binding var genresSelected: [String]
//    @Binding var ratingSelected: Double
//    @Binding var watchSelected: String?
    
    let watchOptions = ["Any", "Watched", "Not Watched"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                VStack {
                    Text("Filters")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.text)
                    Divider()
                    List {
                        watchedFilter
                    }
                    .listRowBackground(Color.theme.genreText)
                    .listStyle(.grouped)
                    .transition(.slide)
                    
                    ForEach(homeVM.convertGenreIDToGenre(for: selectedTab)) { genre in
                        Text(genre.name)
                    }
                }
                .overlay(alignment: .topLeading) {
                    Image(systemName: "xmark")
                        .padding(.leading)
                }
                .padding(.top)
            }
        }
        .onAppear { homeVM.getMediaWatchlists() }
        .navigationTitle("Filters")
    }
}

struct FilterModalView_Previews: PreviewProvider {
    static var previews: some View {
        FilterModalView(selectedTab: .movies)
    }
}

extension FilterModalView {
    private var watchedFilter: some View {
        NavigationLink {
            Text("Watched")
            List(watchOptions, id: \.self, selection: $homeVM.watchSelected) { watchOption in
                Text(watchOption)
            }
            .listRowBackground(Color.theme.red)
            .transition(.slide)
        } label: {
            HStack {
                Text("Watched")
                Spacer()
                Text("\(homeVM.watchSelected ?? "Hi")")
            }
        }
        .navigationTitle("Filters")
        .navigationBarHidden(true)
    }
}

struct ListElement {
    @State var title: String
    @Binding var value: String
    @State var options: [String]
}
