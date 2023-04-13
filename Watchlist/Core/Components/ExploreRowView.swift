//
//  ExploreRowView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/27/23.
//

import SwiftUI

struct ExploreRowView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State var personalRating: Double?
    
    @State var isWatched: Bool = false
    
    @State var media: DBMedia
    
    @State var currentTab: Tab
    
    @State private var showingSheet = false
    
    @State var addedToWatchlist: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            if let posterPath = media.posterPath {
                ThumbnailView(imagePath: posterPath, frameHeight: 80)
            }
            
            centerColumn
            
            Spacer()
            
            rightColumn
        }
        .onTapGesture {
            homeVM.hapticFeedback.impactOccurred()
            showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet, onDismiss: {
            Task {
                let newMedia = try await WatchlistManager.shared.getUpdatedUserMedia(media: media)
                isWatched = newMedia.watched
                personalRating = newMedia.personalRating
            }
        }, content: {
            MediaModalView(media: media)
        })
        .onAppear {
            Task {
                let newMedia = try await WatchlistManager.shared.getUpdatedUserMedia(media: media)
                isWatched = newMedia.watched
                personalRating = newMedia.personalRating
            }
        }
    }
}

struct ExploreRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreRowView(media: dev.mediaMock.first!!, currentTab: .movies)
            .previewLayout(.sizeThatFits)
            .environmentObject(dev.homeVM)
    }
}

extension ExploreRowView {
    var centerColumn: some View {
        VStack(alignment: .leading) {
            if let mediaType = media.mediaType,
               let title = mediaType == .movie ? media.title : media.name {
                Text(title)
                    .font(Font.system(.headline, design: .default))
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color.theme.text)
                    .lineLimit(2)
            }
                
                if let mediaType = media.mediaType, mediaType == .tv {
                    Text("TV Series")
                        .font(.caption)
                        .foregroundColor(Color.theme.text.opacity(0.6))
                }
            
            if let genres = getGenres(genreIDs: media.genreIDs) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Array(zip(genres.indices, genres)), id: \.0) { idx, genre in
                            if idx < 2 {
                                GenreView(genreName: genre.name)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxHeight: 75)
    }
    
    var rightColumn: some View {
        Text(!isInMedia(media: media) ? "Add" : "Added")
            .foregroundColor(!isInMedia(media: media) ? Color.theme.red : Color.theme.genreText)
            .font(.subheadline)
            .fontWeight(.semibold)
            .frame(width: 80, height: 30)
            .background(!isInMedia(media: media) ? Color.theme.secondary : Color.theme.red)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .fixedSize(horizontal: true, vertical: false)
            .onTapGesture {
                homeVM.hapticFeedback.impactOccurred()
                Task {
                    if !isInMedia(media: media) {
                        try await WatchlistManager.shared.createNewMediaInWatchlist(media: media)
                    } else {
                        try await WatchlistManager.shared.deleteMediaInWatchlist(media: media)
                    }
                    
                    try await homeVM.getWatchlists()
                }
            }
            .padding(.leading)
    }
    
    func isInMedia(media: DBMedia) -> Bool {
        let mediaList = homeVM.movieList + homeVM.tvList
        for homeMedia in mediaList {
            if homeMedia.id == media.id {
                return true
            }
        }
        return false
    }
    
    func getGenres(genreIDs: [Int]?) -> [Genre]? {
        guard let genreIDs else { return nil }
        return homeVM.getGenresForMediaType(for: media.mediaType ?? .movie, genreIDs: genreIDs)
    }
}

