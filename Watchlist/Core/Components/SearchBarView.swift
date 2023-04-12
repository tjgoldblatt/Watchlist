//
//  SearchBarView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI
import Combine
import Blackbird

struct SearchBarView: View {
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    @StateObject private var textObserver = TextFieldObserver()
    
    @Binding var searchText: String
    
    @FocusState private var isFocused: Bool
    
    @BlackbirdLiveModels({ try await MediaModel.read(from: $0, matching: \.$mediaType == MediaType.movie.rawValue, orderBy: .ascending(\.$title)) }) var movieList
    
    @BlackbirdLiveModels({ try await MediaModel.read(from: $0, matching: \.$mediaType == MediaType.tv.rawValue, orderBy: .ascending(\.$title)) }) var tvList
    
    
    @State var showFilterSheet: Bool = false
    
    var textFieldString: String {
        return homeVM.selectedTab.searchTextLabel
    }
    
    var queryToCallWhenTyping: (() -> Void)? = nil
    
    var mediaListWithFilter: [Media] {
        var mediaList: Set<Media> = []
        
        switch homeVM.selectedTab {
            case .movies:
                let movieListAfterFilter = movieList.results.filter {
                    switch homeVM.watchSelected {
                        case .unwatched:
                            return !$0.watched
                        case .watched:
                            return $0.watched
                        case .any:
                            return true
                    }
                }
                
                for movieModel in movieListAfterFilter {
                    if let media = homeVM.decodeData(with: movieModel.media) {
                        mediaList.insert(media)
                    }
                }
                
            case .tvShows:
                let tvListAfterFilter = tvList.results.filter {
                    switch homeVM.watchSelected {
                        case .unwatched:
                            return !$0.watched
                        case .watched:
                            return $0.watched
                        case .any:
                            return true
                    }
                }
                
                for tvModel in tvListAfterFilter {
                    if let media = homeVM.decodeData(with: tvModel.media) {
                        mediaList.insert(media)
                    }
                }
            case .explore:
                for media in homeVM.results {
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
            .onAppear { homeVM.getMediaWatchlists() }
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
                return !tvList.results.isEmpty
            case .movies:
                return movieList.results.count > 1
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
                if !t.isEmpty {
                    self?.debouncedText = t
                }
            }
            .store(in: &subscriptions)
    }
}
