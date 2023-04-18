//
//  RowView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI
import Blackbird

struct RowView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State var personalRating: Double?
    
    @State var isWatched: Bool = false
    
    @State var media: DBMedia
    
    @State var currentTab: Tab
    
    @State private var showingSheet = false
    /// For showing the rating modal on swipe - need to work on still
    @State private var showRatingSheet = false
    
    var body: some View {
        HStack(alignment: .center) {
            if let posterPath = media.posterPath {
                ThumbnailView(imagePath: posterPath)
            }
            
            centerColumn
            
            rightColumn
        }
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .accessibilityIdentifier("RowView")
        .sheet(isPresented: $showRatingSheet, onDismiss: {
            if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: media.id) {
                media = updatedMedia
            }
        }) {
            RatingModalView(media: media, shouldShowRatingModal: $showRatingSheet)
        }
        .onTapGesture {
            homeVM.hapticFeedback.impactOccurred()
            showingSheet = true
        }
        .sheet(isPresented: $showingSheet, onDismiss: {
            if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: media.id) {
                media = updatedMedia
            }
        }) {
            MediaModalView(media: media)
        }
        .swipeActions(edge: .trailing) {
            if !isWatched {
                swipeActionToSetWatched
            }
        }
        .onAppear {
            if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: media.id) {
                media = updatedMedia
            }
        }
        .onReceive(media.mediaType == .movie ? homeVM.$movieList : homeVM.$tvList) { updatedList in
            for updatedMedia in updatedList {
                if media.id == updatedMedia.id {
                    media = updatedMedia
                }
            }
        }
        
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        RowView(media: dev.mediaMock.first!, currentTab: .movies)
            .previewLayout(.sizeThatFits)
            .environmentObject(dev.homeVM)
    }
}

extension RowView {
    var centerColumn: some View {
        VStack(alignment: .leading) {
            if let title = media.mediaType == .movie ? media.title : media.name {
                Text(title)
                    .font(Font.system(.headline, design: .default))
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color.theme.text)
                    .lineLimit(2)
                    .frame(alignment: .top)
                    .padding(.bottom, 1)
            }
            Text(media.overview ?? "")
                .font(.system(.caption, design: .default))
                .fixedSize(horizontal: false, vertical: true)
                .fontWeight(.light)
                .foregroundColor(Color.theme.text)
                .lineLimit(3)
            
            if let genres = getGenres(genreIDs:  media.genreIDs) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(zip(genres.indices, genres)), id: \.0) { idx, genre in
                            GenreView(genreName: genre.name)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 50)
    }
    
    var rightColumn: some View {
        VStack(spacing: 10) {
            if let voteAverage = media.voteAverage {
                StarRatingView(text: "IMDb RATING", rating: voteAverage)
            }
            
            if let rating = media.personalRating {
                StarRatingView(text: "YOUR RATING", rating: rating)
            }
            
            if media.watched {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.theme.red)
                    .imageScale(.large)
            }
        }
    }
    
    private var swipeActionToSetWatched: some View {
        Button {
            if personalRating == nil {
                showRatingSheet = true
            }
        } label: {
            Image(systemName: "checkmark.circle")
        }
        .tint(Color.theme.secondary)
        .accessibilityIdentifier("MediaSwipeAction")
    }
    
    func isMediaInWatchlist(media: DBMedia) -> Bool {
        for watchlistMedia in homeVM.tvList + homeVM.movieList {
            if watchlistMedia == media { return true }
        }
        return false
    }
    
    func getGenres(genreIDs: [Int]?) -> [Genre]? {
        guard let genreIDs else { return nil }
        return homeVM.getGenresForMediaType(for: media.mediaType, genreIDs: genreIDs)
    }
}

struct ThumbnailView: View {
    @State var imagePath: String
    @ScaledMetric(relativeTo: .title) var frameHeight: CGFloat = 120
    var frameWidth: CGFloat {
        return frameHeight * 0.70
    }
    
    var body: some View {
        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original\(imagePath)")) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )
            } else if phase.error != nil {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original\(imagePath)")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                            )
                    } else if phase.error != nil {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.theme.secondary)
                            .overlay(alignment: .center) {
                                Image(systemName: "photo")
                                    .resizable()
                                    .foregroundColor(Color.theme.red)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: frameWidth/2)
                                    .offset(x: -2)
                            }
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.theme.secondary)
                            .overlay(alignment: .center) {
                                ProgressView()
                                    .foregroundColor(Color.theme.text)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: frameWidth/2)
                                    .offset(x: -2)
                            }
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.theme.secondary)
                    .overlay(alignment: .center) {
                        ProgressView()
                            .foregroundColor(Color.theme.text)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: frameWidth/2)
                            .offset(x: -2)
                    }
            }
        }
        .frame(width: frameWidth, height: frameHeight)
        .shadow(color: Color.black.opacity(0.2), radius: 5)
        .padding(.trailing, 5)
    }
}
