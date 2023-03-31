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
    
    @ObservedObject var vm = FilterModalViewModel()
    
    @State var genresToFilter: [Genre]
    @State var genresSelected: Set<Genre> = []
    
    let watchOptions = ["Unwatched", "Watched", "Any"]
    
    @State var showWatchedModal = false
    
    @State var screenWidth: CGFloat = 0
    
    @State var sortingOptions = ["Alphabetical", "Rating (High to Low)", "Rating (Low to High)"]
    
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
                        
                        VStack(spacing: 20) {
                            if homeVM.selectedTab != .explore {
                                watchedFilter
                            }
                            
                            if !genresToFilter.isEmpty {
                                genreFilter
                            }
                            
                            ratingFilter
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("SORTING")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.theme.text.opacity(0.6))
                            .padding(.bottom)
                        
                        
                        VStack(spacing: 20) {
                            ForEach(sortingOptions, id: \.self) { option in
                                Text(option)
                                    .fontWeight(homeVM.sortingSelected == option ? .semibold : .medium)
                                    .foregroundColor(homeVM.sortingSelected == option ? Color.theme.red : Color.theme.text)
                                    .onTapGesture {
                                        homeVM.sortingSelected = option
                                        dismiss()
                                    }
                            }
                        }
                    }
                    .padding(.bottom, 50)
                    
                    Spacer()
                    HStack(spacing: 40) {
                        Button("Clear") {
                            dismiss()
                            homeVM.genresSelected = []
                            homeVM.ratingSelected = 0
                        }
                        .foregroundColor(Color.theme.genreText)
                        .frame(width: 100, height: 40)
                        .background(Color.theme.secondary)
                        .cornerRadius(10)
                        
                        Button("Done") {
                            homeVM.genresSelected = genresSelected
                            dismiss()
                        }
                            .foregroundColor(Color.theme.genreText)
                            .frame(width: 100, height: 40)
                            .background(Color.theme.red)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            homeVM.getMediaWatchlists()
            genresSelected = homeVM.genresSelected
        }
    }
}

struct FilterModalView_Previews: PreviewProvider {
    static var previews: some View {
        FilterModalView(genresToFilter: [Genre(id: 1, name: "Adventure"), Genre(id: 1, name: "Action"), Genre(id: 1, name: "Science Fiction"), Genre(id: 1, name: "Fantasy")])
            .environmentObject(dev.homeVM)
    }
}

extension FilterModalView {
    private var watchedFilter: some View {
        VStack {
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
            .padding(.bottom)
        }
    }
    
    private var genreFilter: some View {
        VStack {
            Text("Genres")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.text)
            
            FlexibleView(availableWidth: screenWidth, data: sortedGenreList(genresToFilter: genresToFilter), spacing: 10, alignment: .center) { genreOption in
                Text(genreOption.name)
                    .foregroundColor(genresSelected.contains(genreOption) ? Color.theme.genreText : Color.theme.text.opacity(0.6))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fixedSize(horizontal: true, vertical: true)
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .background {
                        Capsule()
                            .strokeBorder(genresSelected.contains(genreOption) ? Color.clear : Color.theme.secondary, lineWidth: 2)
                        Capsule()
                            .foregroundColor(genresSelected.contains(genreOption) || genresSelected.contains(genreOption) ? Color.theme.red : Color.clear)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !genresSelected.contains(genreOption) {
                            genresSelected.insert(genreOption)
                        } else {
                            genresSelected.remove(genreOption)
                        }
                    }
            }
            .readSize { newSize in
                screenWidth = newSize.width
            }
        }
    }
    
    private var ratingFilter: some View {
        VStack {
            Text("Rating")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.text)
                .padding(.bottom)
            
            StarsView(rating: $homeVM.ratingSelected)
        }
        .padding(.vertical)
    }
    
    func sortedGenreList(genresToFilter: [Genre]) -> [Genre] {
        return genresToFilter
            .sorted(by: { genre1, genre2 in
                genre1.name.lowercased() < genre2.name.lowercased()
            })
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
                    Spacer()
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .readSize { size in
                                elementsSize[element] = size
                            }
                    }
                    Spacer()
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
