//
//  SearchBarView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI
import Combine

struct SearchBarView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    
    @StateObject private var textObserver = TextFieldObserver()
    
    @Binding var searchText: String
    
    @FocusState private var isFocused: Bool
    
    @State var showFilterSheet: Bool = false
    
    var textFieldString: String {
        return homeVM.selectedTab.searchTextLabel
    }
    
    var queryToCallWhenTyping: (() -> Void)? = nil
    
    var mediaListWithFilter: [DBMedia] {
        var mediaList: Set<DBMedia> = []
        
        switch homeVM.selectedTab {
            case .movies:
                let movieListAfterFilter = homeVM.movieList.filter {
                    switch homeVM.watchSelected {
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
                    switch homeVM.watchSelected {
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
                for media in homeVM.results.map({ DBMedia(media: $0, watched: false, personalRating: nil) }) {
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
                        if isFocused && !(homeVM.selectedTab == .explore ? textObserver.searchText.isEmpty : searchText.isEmpty) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding()
                                .offset(x: 15)
                                .foregroundColor(Color.theme.text)
                                .opacity(!isFocused ? 0.0 : 1.0)
                                .onTapGesture {
                                    homeVM.hapticFeedback.impactOccurred()
                                    searchText = ""
                                    textObserver.searchText = ""
                                    if homeVM.selectedTab == .explore {
                                        homeVM.results = []
                                    }
                                }
                        } else if shouldShowFilterButton {
                            Image(systemName: "slider.horizontal.3")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .padding()
                                .offset(x: 15)
                                .foregroundColor(Color.theme.red)
                                .opacity(!isFocused ? 1.0 : 0.0)
                                .onTapGesture {
                                    homeVM.hapticFeedback.impactOccurred()
                                    showFilterSheet.toggle()
                                }
                        }
                    }
                    .sheet(isPresented: $showFilterSheet) {
                        FilterModalView(genresToFilter: homeVM.convertGenreIDToGenre(for: homeVM.selectedTab, watchList: mediaListWithFilter))
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                    }
                    .submitLabel(.search)
                    .onReceive(textObserver.$debouncedText) { val in
                        homeVM.searchText = val
                        
                        if homeVM.selectedTab == .explore && val.isEmpty {
                            homeVM.results = []
                        }
                        
                        if(!textObserver.searchText.isEmpty) {
                            if let queryToCallWhenTyping {
                                queryToCallWhenTyping()
                            }
                        }
                    }
            }
            .font(.headline)
            .padding()
            .frame(height: 50)
            .contentShape(RoundedRectangle(cornerRadius: 20))
            .background(Color.theme.secondary)
            .cornerRadius(20)
            .task { try? await homeVM.getWatchlists() }
            .onTapGesture {
                withAnimation(.spring()) {
                    isFocused = true
                }
            }
        }
        .onChange(of: homeVM.watchSelected) { _ in
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
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant(""))
            .environmentObject(dev.homeVM)
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
                    .map { _ in false })
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

class TextFieldObserver : ObservableObject {
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
