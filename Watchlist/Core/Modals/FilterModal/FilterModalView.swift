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
    
    @State var genresToFilter: [Genre]
    
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
                    
                    List {
                        watchedFilter
                        
                        if !genresToFilter.isEmpty {
                            genreFilter
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.grouped)
                    .transition(.slide)
                }
                .overlay(alignment: .topLeading) {
                    Image(systemName: "xmark")
                        .padding(.leading)
                        .padding(.top, 5)
                        .onTapGesture {
                            dismiss()
                        }
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
        FilterModalView(selectedTab: .movies, genresToFilter: [Genre(id: 1, name: "Science")])
            .environmentObject(dev.homeVM)
    }
}

extension FilterModalView {
    private var watchedFilter: some View {
        NavigationLink {
            List(watchOptions, id: \.self) { watchOption in
                HStack {
                    Text(watchOption)
                    
                    Spacer()
                    
                    if homeVM.watchSelected == watchOption {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.theme.red)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if homeVM.watchSelected != watchOption {
                        homeVM.watchSelected = watchOption
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.theme.background)
            .transition(.slide)
        } label: {
            HStack {
                Text("Watched")
                Spacer()
                Text("\(homeVM.watchSelected)")
            }
        }
        .navigationTitle("Filters")
        .navigationBarHidden(true)
    }
    
    private var genreFilter: some View {
        NavigationLink {
            List(sortedGenreList(genresToFilter: genresToFilter), id: \.id) { genreOption in
                HStack {
                    Text(genreOption.name)
                    
                    Spacer()
                    
                    if homeVM.genresSelected.contains(genreOption) {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.theme.red)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if !homeVM.genresSelected.contains(genreOption) {
                        homeVM.genresSelected.insert(genreOption)
                    } else {
                        homeVM.genresSelected.remove(genreOption)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.theme.background)
            .transition(.slide)
        } label: {
            HStack {
                Text("Genres")
                Spacer()
                if homeVM.genresSelected.count == genresToFilter.count {
                    Text("Any")
                } else if homeVM.genresSelected.count > 1 {
                    Text("Multiple Genres")
                } else {
                    Text("\(homeVM.genresSelected.first?.name ?? "Any")")
                }
            }
        }
        .navigationTitle("Filters")
        .navigationBarHidden(true)
    }
    
    func sortedGenreList(genresToFilter: [Genre]) -> [Genre] {
        return genresToFilter
            .sorted(by: { genre1, genre2 in
                genre1.name.lowercased() < genre2.name.lowercased()
            })
            .sorted { genre1, genre2 in
            return homeVM.genresSelected.contains(genre1) && !homeVM.genresSelected.contains(genre2)
        }
    }
}

struct ListElement {
    @State var title: String
    @Binding var value: String
    @State var options: [String]
}
