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
    
    @Binding var searchText: String
    
    @State var isKeyboardShowing: Bool = false
    
    @BlackbirdLiveModels({ try await MediaModel.read(from: $0, matching: \.$mediaType == MediaType.movie.rawValue, orderBy: .ascending(\.$title)) }) var movieList
    
    @BlackbirdLiveModels({ try await MediaModel.read(from: $0, matching: \.$mediaType == MediaType.tv.rawValue, orderBy: .ascending(\.$title)) }) var tvList
    
    
    @State var showFilterSheet: Bool = false
    
    var textFieldString: String {
        return homeVM.selectedTab.searchTextLabel
    }
    
    var queryToCallWhenTyping: () -> Void
    
    var mediaList: [Media] {
        var mediaList: Set<Media> = []
        switch homeVM.selectedTab {
            case .movies:
                for movieModel in movieList.results {
                    if let media = homeVM.decodeData(with: movieModel.media) {
                        mediaList.insert(media)
                    }
                }
            case .tvShows:
                for tvModel in tvList.results {
                    if let media = homeVM.decodeData(with: tvModel.media) {
                        mediaList.insert(media)
                    }
                }
            case .explore:
                for media in homeVM.results {
                    mediaList.insert(media)
                }
        }
        return Array(mediaList)
    }
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(!isKeyboardShowing ? Color.theme.red : Color.theme.text)
                    .imageScale(.medium)
                
                TextField(textFieldString, text: $searchText)
                    .foregroundColor(Color.theme.text)
                    .font(.system(size: 16, design: .default))
                    .onReceive(keyboardPublisher) { value in
                        withAnimation(.spring()) {
                            isKeyboardShowing = value
                        }
                    }
                    .onSubmit {
                        isKeyboardShowing = false
                        hideKeyboard()
                    }
                    .onTapGesture {
                        withAnimation(.spring()) {
                            isKeyboardShowing = true
                        }
                    }
                    .overlay(alignment: .trailing, content: {
                        if isKeyboardShowing && !searchText.isEmpty {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding()
                                .offset(x: 15)
                                .foregroundColor(Color.theme.text)
                                .opacity(!isKeyboardShowing ? 0.0 : 1.0)
                                .onTapGesture {
                                    homeVM.hapticFeedback.impactOccurred()
                                    searchText = ""
                                }
                        } else if shouldShowFilterButton {
                            Image(systemName: "slider.horizontal.3")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .padding()
                                .offset(x: 15)
                                .foregroundColor(Color.theme.red)
                                .opacity(!isKeyboardShowing ? 1.0 : 0.0)
                                .onTapGesture {
                                    homeVM.hapticFeedback.impactOccurred()
                                    showFilterSheet.toggle()
                                }
                        }
                    })
                    .sheet(isPresented: $showFilterSheet) {
                        FilterModalView(genresToFilter: homeVM.convertGenreIDToGenre(for: homeVM.selectedTab, watchList: mediaList))
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                    }
                    .submitLabel(.search)
                    .onChange(of: searchText) { newValue in
                        if(!searchText.isEmpty) {
                            queryToCallWhenTyping()
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
        }
    }
    
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant("")) {
            //
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
                    .map { _ in false })
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
