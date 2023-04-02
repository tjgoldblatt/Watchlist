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
        .accessibilityIdentifier("RowView")
        .sheet(isPresented: $showRatingSheet, onDismiss: {
            Task {
                await database?.fetchPersonalRating(media: media) { rating in
                    personalRating = rating
                    homeVM.getMediaWatchlists()
                }
                if personalRating != nil {
                    await database?.setWatched(watched: true, media: media)
                    await database?.fetchIsWatched(media: media) { watched in
                        isWatched = watched
                    }
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
                }
                await database?.fetchIsWatched(media: media) { watched in
                    isWatched = watched
                }
                homeVM.getMediaWatchlists()
            }
        }) {
            MediaModalView(mediaDetails: rowContent, media: media)
        }
        .swipeActions(edge: .trailing) {
            if !isWatched {
                swipeActionToSetWatched
            }
        }
        .onAppear {
            Task {
                await database?.fetchIsWatched(media: media) { watched in
                    isWatched = watched
                }
                await database?.fetchPersonalRating(media: media) { rating in
                    personalRating = rating
                }
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
    
    private var swipeActionToSetUnwatched: some View {
        Button {
            Task {
                await database?.setWatched(watched: false, media: media)
                await database?.fetchIsWatched(media: media) { watched in
                    isWatched = watched
                }
            }
        } label: {
            Image(systemName: "film.stack")
        }
        .tint(Color.green)
        .accessibilityIdentifier("MediaSwipeAction")
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
                    .padding(.trailing, 5)
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
            } else if phase.error != nil {
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original\(imagePath)")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                            )
                            .padding(.trailing, 5)
                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                    } else if phase.error != nil {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.theme.secondary)
                            .padding(.trailing, 5)
                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                            .frame(width: frameWidth)
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
                            .padding(.trailing, 5)
                            .shadow(color: Color.black.opacity(0.2), radius: 5)
                            .frame(width: frameWidth)
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
                    .padding(.trailing, 5)
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                    .frame(width: frameWidth)
                    .overlay(alignment: .center) {
                        ProgressView()
                            .foregroundColor(Color.theme.text)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: frameWidth/2)
                            .offset(x: -2)
                    }
            }
        }.frame(height: frameHeight)
    }
}
