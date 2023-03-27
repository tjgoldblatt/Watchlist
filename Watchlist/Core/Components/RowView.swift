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
    
    var body: some View {
        HStack(alignment: .center) {
            ThumbnailView(imagePath: "\(rowContent.posterPath)")
            
            centerColumn
            
            rightColumn
        }
        // TODO: Show rating sheet when swiping to mark as Watched
        .sheet(isPresented: $showRatingSheet) {
            RatingModalView(media: media) {
                Task {
                    await database?.fetchPersonalRating(media: media) { rating in
                        personalRating = rating
                    }
                }
            }
        }
        .onTapGesture {
            showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet) {
            MediaModalView(mediaDetails: rowContent, media: media) {
                Task {
                    await database?.fetchPersonalRating(media: media) { rating in
                        personalRating = rating
                    }
                }
            }
            .interactiveDismissDisabled()
        }
        .swipeActions(edge: .trailing) {
            if currentTab == .explore {
                searchTabSwipeAction
            } else {
                mediaTabSwipeAction
            }
        }
        .onAppear {
            Task {
                await database?.fetchIsWatched(media: media) { watched in
                    isWatched = watched
                }
                await database?.fetchPersonalRating(media: media, completionHandler: { rating in
                    personalRating = rating
                })
            }
        }
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        RowView(rowContent: dev.rowContent, media: dev.mediaMock.first!, currentTab: .movies)
            .previewLayout(.sizeThatFits)
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
            
            if let rating = personalRating {
                StarRatingView(text: "YOUR RATING", rating: rating)
            }
            
            if isWatched {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.theme.red)
                    .imageScale(.large)
            }
        }
    }
    
    private var mediaTabSwipeAction: some View {
        //        Group {
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
                    
                    await database?.fetchPersonalRating(media: media, completionHandler: { rating in
                        personalRating = rating
                    })
                }
            }
        } label: {
            Image(systemName: "film.stack")
        }
        .tint(Color.theme.secondary)
    }
    
    private var searchTabSwipeAction: some View {
        Button {
            database?.saveMedia(media: media)
        } label: {
            Image(systemName: "film.stack")
        }
        .tint(Color.theme.secondary)
    }
}

struct ThumbnailView: View {
    @State var imagePath: String
    var body: some View {
        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(imagePath)")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                    
                )
                .frame(height: 120)
                .padding(.trailing, 5)
        } placeholder: {
            ProgressView()
        }
    }
}
