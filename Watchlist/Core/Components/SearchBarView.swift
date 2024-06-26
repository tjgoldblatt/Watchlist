//
//  SearchBarView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Combine
import SwiftUI

struct SearchBarView: View {
    @EnvironmentObject var homeVM: HomeViewModel

    @StateObject private var textObserver = TextFieldObserver()

    @Binding var searchText: String

    @FocusState private var isFocused: Bool

    var textFieldString: String {
        return homeVM.selectedTab.searchTextLabel
    }

    var queryToCallWhenTyping: (() -> Void)?

    var mediaListWithFilter: [DBMedia] {
        var mediaList: Set<DBMedia> = []

        switch homeVM.selectedTab {
            case .movies:
                let movieListAfterFilter = homeVM.movieList.filter {
                    switch homeVM.selectedWatchOption {
                        case .unwatched:
                            return !$0.watched
                        case .watched:
                            return $0.watched
                        case .any:
                            return true
                    }
                }

                for movie in movieListAfterFilter {
                    mediaList.insert(movie)
                }

            case .tvShows:
                let tvListAfterFilter = homeVM.tvList.filter {
                    switch homeVM.selectedWatchOption {
                        case .unwatched:
                            return !$0.watched
                        case .watched:
                            return $0.watched
                        case .any:
                            return true
                    }
                }

                for tvShow in tvListAfterFilter {
                    mediaList.insert(tvShow)
                }
            case .explore:
                for media in homeVM.results.compactMap({
                    try? DBMedia(media: $0, currentlyWatching: false, bookmarked: false, watched: false, personalRating: nil)
                }) {
                    mediaList.insert(media)
                }
            case .social:
                break
        }
        return Array(mediaList)
    }

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(!isFocused ? Color.theme.red : Color.theme.text)
                    .imageScale(.medium)

                TextField(textFieldString, text: homeVM.selectedTab == .explore ? $textObserver.searchText : $searchText)
                    .foregroundColor(Color.theme.text)
                    .font(.system(size: 16, design: .default))
                    .focused($isFocused)
                    .overlay(alignment: .trailing) {
                        if isFocused, !(homeVM.selectedTab == .explore ? textObserver.searchText.isEmpty : searchText.isEmpty) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding()
                                .offset(x: 15)
                                .foregroundColor(Color.theme.text)
                                .opacity(!isFocused ? 0.0 : 1.0)
                                .onTapGesture {
                                    searchText = ""
                                    textObserver.searchText = ""
                                    if homeVM.selectedTab == .explore {
                                        homeVM.results = []
                                    }
                                }
                        } else if shouldShowFilterButton {
                            FilterMenu()
                                .onTapGesture {
                                    isFocused = false
                                }
                        }
                    }
                    .submitLabel(.search)
                    .onReceive(textObserver.$debouncedText) { val in
                        homeVM.searchText = val

                        if homeVM.selectedTab == .explore, val.isEmpty {
                            homeVM.results = []
                        }

                        if !textObserver.searchText.isEmpty {
                            if let queryToCallWhenTyping {
                                queryToCallWhenTyping()
                            }
                        }
                    }
                    .onChange(of: homeVM.searchText) { text in
                        if homeVM.selectedTab == .explore, text.isEmpty {
                            searchText = ""
                            textObserver.searchText = ""
                        }
                    }
            }
            .font(.headline)
            .padding()
            .frame(height: 50)
            .contentShape(Capsule())
            .background(Capsule().fill(Color.theme.secondary))
            .onTapGesture {
                withAnimation(.spring()) {
                    AnalyticsManager.shared.logEvent(name: "SearchBar_Tapped")
                    isFocused = true
                }
            }
        }
        .dynamicTypeSize(.medium ... .xLarge)
        .onChange(of: homeVM.selectedWatchOption) { _ in
            isFocused = false
        }
        .padding(.horizontal)
    }

    var shouldShowFilterButton: Bool {
        switch homeVM.selectedTab {
            case .tvShows:
                return !homeVM.tvList.isEmpty
            case .movies:
                return !homeVM.movieList.isEmpty
            case .explore:
                return !homeVM.results.isEmpty
            case .social:
                return false
        }
    }

    @ViewBuilder
    func FilterMenu() -> some View {
        Menu {
            Button {
                homeVM.filterByBookmarked.toggle()
                homeVM.filterByCurrentlyWatching = false
            } label: {
                if homeVM.filterByBookmarked {
                    Label("Bookmarked", systemImage: "checkmark")
                } else {
                    Text("Bookmarked")
                }
            }

            if homeVM.selectedWatchOption != .watched {
                Button {
                    homeVM.filterByCurrentlyWatching.toggle()
                    homeVM.filterByBookmarked = false
                } label: {
                    if homeVM.filterByCurrentlyWatching {
                        Label("Watching", systemImage: "checkmark")
                    } else {
                        Text("Watching")
                    }
                }
            }

            ForEach(SortingOptions.allCases, id: \.self) { option in
                Button {
                    withAnimation(.easeInOut) {
                        homeVM.selectedSortingOption = option
                    }
                    AnalyticsManager.shared.logEvent(name: "\(option.rawValue)_Tapped")
                } label: {
                    if homeVM.selectedSortingOption == option {
                        Label(option.rawValue, systemImage: "checkmark")
                    } else {
                        Text(option.rawValue)
                    }
                }
            }

            let genres = homeVM.convertGenreIDToGenre(for: homeVM.selectedTab, watchList: mediaListWithFilter)
                .sorted { $0.name < $1.name }

            Menu("Genres") {
                Button {
                    homeVM.genresSelected = []
                } label: {
                    if homeVM.genresSelected.isEmpty {
                        Label("All", systemImage: "checkmark")
                    } else {
                        Text("All")
                    }
                }

                ForEach(genres, id: \.self) { genre in
                    Button {
                        homeVM.genresSelected = []
                        homeVM.genresSelected.insert(genre)
                        AnalyticsManager.shared.logEvent(name: "\(genre.name)_Tapped")
                    } label: {
                        if homeVM.genresSelected.contains(genre) {
                            Label(genre.name, systemImage: "checkmark")
                        } else {
                            Text(genre.name)
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding()
                .offset(x: 15)
                .foregroundColor(Color.theme.red)
                .opacity(!isFocused ? 1.0 : 0.0)
        }
    }
}

extension View {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .Merge(
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true },
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false }
            )
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

class TextFieldObserver: ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""

    private var subscriptions = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] t in
                self?.debouncedText = t
            }
            .store(in: &subscriptions)
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant(""))
            .environmentObject(dev.homeVM)
    }
}
