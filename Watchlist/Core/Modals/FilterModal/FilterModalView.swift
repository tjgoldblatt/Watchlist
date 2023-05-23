//
//  FilterModalView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/25/23.
//

import FirebaseAnalyticsSwift
import SwiftUI

struct FilterModalView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @Environment(\.dismiss) var dismiss

    @StateObject var vm = FilterModalViewModel()

    @Namespace private var animation

    @State var genresToFilter: [Genre]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()

                VStack(alignment: .center) {
                    VStack {
                        Text("FILTERS")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.theme.text.opacity(0.6))
                            .padding(.vertical)

                        VStack(spacing: 50) {
                            if !genresToFilter.isEmpty {
                                genreFilter
                            }

                            ratingFilter
                        }
                    }
                    .padding()

                    VStack {
                        Text("SORTING")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.theme.text.opacity(0.6))
                            .padding(.bottom)

                        VStack(spacing: 20) {
                            ForEach(SortingOptions.allCases, id: \.rawValue) { option in
                                Text(option.rawValue)
                                    .fontWeight(homeVM.sortingSelected == option ? .semibold : .medium)
                                    .foregroundColor(homeVM.sortingSelected == option ? Color.theme.red : Color.theme.text)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            homeVM.sortingSelected = option
                                            dismiss()
                                        }
                                    }
                            }
                        }
                    }
                    .padding()

                    Spacer()

                    confirmationButtons
                }
            }
        }
        .analyticsScreen(name: "FilterModalView")
        .task {
            vm.genresSelected = homeVM.genresSelected
        }
    }
}

struct FilterModalView_Previews: PreviewProvider {
    static var previews: some View {
        FilterModalView(genresToFilter: [
            Genre(id: 1, name: "Adventure"),
            Genre(id: 2, name: "Action"),
            Genre(id: 3, name: "Science Fiction"),
            Genre(id: 4, name: "Fantasy"),
            Genre(id: 5, name: "Thriller"),
        ])
        .environmentObject(dev.homeVM)
    }
}

extension FilterModalView {
    private var genreFilter: some View {
        VStack {
            Text("Genres")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.text)

            FlexibleView(
                availableWidth: vm.screenWidth,
                data: sortedGenreList(genresToFilter: genresToFilter),
                spacing: 10,
                alignment: .center)
            { genreOption in
                Text(genreOption.name)
                    .foregroundColor(
                        vm.genresSelected.contains(genreOption)
                            ? Color.theme.genreText
                            : Color.theme.red.opacity(0.6))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .fixedSize(horizontal: true, vertical: true)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                        .background {
                            if vm.genresSelected.contains(genreOption) {
                                Capsule()
                                    .fill(Color.theme.red)
                            } else {
                                Capsule()
                                    .fill(Color.theme.secondary.opacity(0.6))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring()) {
                                if !vm.genresSelected.contains(genreOption) {
                                    vm.genresSelected.insert(genreOption)
                                } else {
                                    vm.genresSelected.remove(genreOption)
                                }
                            }
                        }
            }
            .readSize { newSize in
                DispatchQueue.main.async {
                    vm.screenWidth = newSize.width
                }
            }
        }
    }

    private var ratingFilter: some View {
        VStack {
            Text("Rating")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color.theme.text)

            StarsView(rating: $homeVM.ratingSelected.animation(.spring()))
                .matchedGeometryEffect(id: "star", in: animation)
        }
    }

    private var confirmationButtons: some View {
        HStack {
            Button("Clear") {
                dismiss()
                homeVM.genresSelected = []
                homeVM.ratingSelected = 0
            }
            .foregroundColor(Color.theme.red)
            .fontWeight(.medium)
            .frame(height: 40)
            .frame(minWidth: 150)
            .background(Color.theme.secondary)
            .cornerRadius(10)
            .buttonStyle(.plain)
            .padding()

            Button("Done") {
                homeVM.genresSelected = vm.genresSelected
                dismiss()
            }
            .foregroundColor(Color.theme.genreText)
            .fontWeight(.medium)
            .frame(height: 40)
            .frame(minWidth: 150)
            .background(Color.theme.red)
            .cornerRadius(10)
            .buttonStyle(.plain)
            .padding()
        }
        .padding(.horizontal)
        .padding(.bottom)
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

    var body: some View {
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
            })
            .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value _: inout CGSize, nextValue _: () -> CGSize) { }
}
