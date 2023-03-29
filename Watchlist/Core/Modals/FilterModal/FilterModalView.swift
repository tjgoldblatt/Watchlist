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
    
    let watchOptions = ["Any", "Watched", "Unwatched"]
    
    @State var showWatchedModal = false
    @State var showGenreModal = false
    @State var showRatingModal = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()
                
                VStack {
                    VStack {
                        Text("FILTERS")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.theme.text.opacity(0.6))
                            .padding(.vertical)
                        
                        VStack {
                            watchedFilter
                            
                            if !genresToFilter.isEmpty {
                                genreFilter
                            }
                        }
                    }
                    
                    VStack {
                        Text("SORTING")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.theme.text.opacity(0.6))
                            .padding(.bottom)
                        
                        
                        VStack(spacing: 20) {
                            Text("Alphabetical")
                            Text("Rating (High to Low)")
                            Text("Rating (Low to High)")
                        }
                    }
                    .padding(.bottom, 50)
                    
                    Spacer()
                    HStack(spacing: 40) {
                        Button("Cancel") {
                            dismiss()
                            homeVM.watchSelected = "Any"
                            homeVM.genresSelected = []
                            homeVM.ratingSelected = nil
                        }
                        .foregroundColor(Color.theme.genreText)
                        .frame(width: 100, height: 40)
                        .background(Color.theme.secondary)
                        .cornerRadius(10)
                        
                        Button("Done") { dismiss() }
                            .foregroundColor(Color.theme.genreText)
                            .frame(width: 100, height: 40)
                            .background(Color.theme.red)
                            .cornerRadius(10)
                    }
                }
                .padding(.vertical)
            }
        }
        .onAppear { homeVM.getMediaWatchlists() }
    }
}

struct FilterModalView_Previews: PreviewProvider {
    static var previews: some View {
        FilterModalView(selectedTab: .movies, genresToFilter: [Genre(id: 1, name: "Adventure"), Genre(id: 1, name: "Action"), Genre(id: 1, name: "Science Fiction"), Genre(id: 1, name: "Fantasy")])
            .environmentObject(dev.homeVM)
    }
}

extension FilterModalView {
    private var watchedFilter: some View {
        VStack(alignment: .center) {
            Text("Watched")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.text)
            HStack {
                ForEach(watchOptions, id: \.self) { watchOption in
                    Text(watchOption)
                        .foregroundColor(homeVM.watchSelected == watchOption ? Color.theme.genreText : Color.theme.text.opacity(0.6))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 110, height: 30)
                        .contentShape(Capsule())
                        .background {
                            Capsule()
                                .strokeBorder(homeVM.watchSelected == watchOption ? Color.clear : Color.theme.secondary, lineWidth: 2)
                            Capsule()
                                .foregroundColor(homeVM.watchSelected == watchOption ? Color.theme.red : Color.clear)
                        }
                        .onTapGesture {
                            if homeVM.watchSelected != watchOption {
                                homeVM.watchSelected = watchOption
                            }
                        }
                }
            }
            .padding()
        }
    }
    
    var genreFilter: some View {
        VStack {
            Text("Genres")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.text)
            
            
            GeometryReader { geo in
                FlexibleView(availableWidth: geo.size.width, data: sortedGenreList(genresToFilter: genresToFilter), spacing: 10, alignment: .center) { genreOption in
                    Text(genreOption.name)
                        .foregroundColor(homeVM.genresSelected.contains(genreOption) ? Color.theme.genreText : Color.theme.text.opacity(0.6))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fixedSize(horizontal: true, vertical: true)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .background {
                            Capsule()
                                .strokeBorder(homeVM.genresSelected.contains(genreOption) ? Color.clear : Color.theme.secondary, lineWidth: 2)
                            Capsule()
                                .foregroundColor(homeVM.genresSelected.contains(genreOption) ? Color.theme.red : Color.clear)
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
            }
            .padding(.horizontal)
        }
    }
    
    func sortedGenreList(genresToFilter: [Genre]) -> [Genre] {
        return genresToFilter
            .sorted(by: { genre1, genre2 in
                genre1.name.lowercased() < genre2.name.lowercased()
            })
    }
}

struct FilterOptionRow: View {
    @State var title: String
    @State var isSelected: Bool
    var body: some View {
        HStack {
            Text(title)
                .padding(.trailing)
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(Color.theme.red)
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - FLEXIBLE VIEW

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State var elementsSize: [Data.Element: CGSize] = [:]
    
    var body : some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .readSize { size in
                                elementsSize[element] = size
                            }
                    }
                }
            }
        }
    }
    
    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }
        
        return rows
    }
}


extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
