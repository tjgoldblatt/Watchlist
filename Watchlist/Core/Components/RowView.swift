//
//  RowView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI
import Blackbird

struct RowView: View {
    @Environment(\.blackbirdDatabase) var database
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State var rowContent: MediaDetailContents
    
    @State var personalRating: Double?
    
    @State var isWatched: Bool = false
    
    @State var media: Media
    
    @State var currentTab: Tab
    
    @State private var showingSheet = false
    /// For showing the rating modal on swipe - need to work on still
    @State private var showRatingSheet = false
    
    @State var showPersonalRating = false
    
    var body: some View {
        HStack(alignment: .center) {
            ThumbnailView(imagePath: "\(rowContent.posterPath)")
            
            centerColumn
            
            rightColumn
        }
        // TODO: Show rating sheet when swiping to mark as Watched
        .sheet(isPresented: $showRatingSheet, onDismiss: {
            Task {
                await database?.fetchPersonalRating(media: media) { rating in
                    personalRating = rating
                }
            }
        }) {
            RatingModalView(media: media)
        }
        .onTapGesture {
            showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet, onDismiss: {
            Task {
                await database?.fetchPersonalRating(media: media) { rating in
                    personalRating = rating
                    showPersonalRating = true
                }
            }
        }) {
            MediaModalView(mediaDetails: rowContent, media: media)
            .interactiveDismissDisabled()
        }
        .swipeActions(edge: .trailing) {
            mediaTabSwipeAction
        }
        .onAppear {
            Task {
                await database?.fetchIsWatched(media: media) { watched in
                    isWatched = watched
                }
                await database?.fetchPersonalRating(media: media, completionHandler: { rating in
                    personalRating = rating
                    showPersonalRating = true
                })
            }
        }
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        RowView(rowContent: dev.rowContent, media: dev.mediaMock.first!, currentTab: .movies)
            .previewLayout(.sizeThatFits)
            .environmentObject(dev.homeVM)
    }
}

extension RowView {
    var centerColumn: some View {
        VStack(alignment: .leading) {
            Text(rowContent.title)
                .font(Font.system(.headline, design: .default))
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color.theme.text)
                .lineLimit(2)
                .frame(alignment: .top)
                .padding(.bottom, 1)
            
            Text(rowContent.overview)
                .font(.system(size: 10, design: .default))
                .fixedSize(horizontal: false, vertical: true)
                .fontWeight(.light)
                .foregroundColor(Color.theme.text)
                .lineLimit(4)
            
            Spacer()
            
            if let genres = rowContent.genres {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(zip(genres.indices, genres)), id: \.0) { idx, genre in
                            GenreView(genreName: genre.name)
                        }
                    }
                }
            }
        }
        
        .frame(maxHeight: 115)
        .frame(minWidth: 50)
    }
    
    var rightColumn: some View {
        VStack(spacing: 10) {
            StarRatingView(text: "IMDb RATING", rating: rowContent.imdbRating)
            
            if showPersonalRating {
                if let rating = personalRating {
                    StarRatingView(text: "YOUR RATING", rating: rating)
                }
            }
            
            if isWatched {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.theme.red)
                    .imageScale(.large)
            }
        }
    }
    
    private var mediaTabSwipeAction: some View {
        Button {
            if !isWatched && personalRating == nil {
                showRatingSheet = true
            }
            
            Task {
                if let db = database, let id = media.id {
                    if isWatched {
                        try await MediaModel.update(in: db, set: [\.$watched : false], matching: \.$id == id)
                    } else {
                        try await MediaModel.update(in: db, set: [\.$watched : true], matching: \.$id == id)
                    }
                    await database?.fetchIsWatched(media: media, completionHandler: { watched in
                        isWatched = watched
                    })
                }
            }
        } label: {
            Image(systemName: "film.stack")
        }
        .tint(Color.theme.secondary)
    }
    
    func isMediaInWatchlist(media: Media) -> Bool {
        for watchlistMedia in homeVM.tvWatchlist + homeVM.movieWatchlist {
            if watchlistMedia == media { return true }
        }
        return false
    }
}

struct ThumbnailView: View {
    @State var imagePath: String
    @State var frameHeight: CGFloat = 120
    var body: some View {
        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(imagePath)")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                    
                )
                .frame(height: frameHeight)
                .padding(.trailing, 5)
                .shadow(color: Color.black.opacity(0.2), radius: 10)
        } placeholder: {
            ProgressView()
        }
    }
}
