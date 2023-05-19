//
//  FriendRowView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/9/23.
//

import NukeUI
import SwiftUI

struct FriendRowView: View {
    @EnvironmentObject var homeVM: HomeViewModel

    @State var personalRating: Double?

    @State var isWatched: Bool = false

    @State var media: DBMedia

    @State private var showingSheet = false

    var friendName: String

    var body: some View {
        HStack(alignment: .center) {
            if let posterPath = media.posterPath {
                ThumbnailView(imagePath: posterPath)
                    .overlay(alignment: .topTrailing) {
                        if homeVM.isMediaIDInWatchlist(for: media.id) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .foregroundStyle(Color.theme.genreText, Color.theme.red)
                                .offset(x: -10, y: 5)
                        }
                    }
            }

            centerColumn

            rightColumn
        }
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .accessibilityIdentifier("FriendRowView")
        .contentShape(Rectangle())
        .onTapGesture {
            showingSheet = true
        }
        .sheet(isPresented: $showingSheet) {
            MediaModalView(media: media, friendName: friendName)
        }
        .swipeActions(edge: .trailing) {
            if !homeVM.isMediaIDInWatchlist(for: media.id) {
                swipeActionToAddToWatchlist
            } else {
                swipeActionToRemoveFromWatchlist
            }
        }
    }
}

extension FriendRowView {
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

            if let genres = getGenres(genreIDs: media.genreIDs) {
                ScrollView(.horizontal, showsIndicators: false) {
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
        .frame(minWidth: 50)
    }

    var rightColumn: some View {
        VStack(spacing: 20) {
            if let voteAverage = media.voteAverage {
                StarRatingView(text: "IMDb RATING", rating: voteAverage)
            }

            if let rating = media.personalRating {
                StarRatingView(text: "\(friendName.uppercased())'S RATING", rating: rating)
            }
        }
    }

    private var swipeActionToAddToWatchlist: some View {
        Button {
            Task {
                var newMedia = media
                newMedia.watched = false
                newMedia.personalRating = nil
                try await WatchlistManager.shared.createNewMediaInWatchlist(media: newMedia)
            }
            AnalyticsManager.shared.logEvent(name: "FriendRowView_SwipeAction_Add")

        } label: {
            Image(systemName: "plus.circle.fill")
        }
        .tint(Color.theme.secondaryBackground)
        .accessibilityIdentifier("AddToWatchlistSwipeAction")
    }

    private var swipeActionToRemoveFromWatchlist: some View {
        Button {
            Task {
                try await WatchlistManager.shared.deleteMediaInWatchlist(media: media)
            }
            AnalyticsManager.shared.logEvent(name: "FriendRowView_SwipeAction_Delete")

        } label: {
            Image(systemName: "xmark")
        }
        .tint(Color.theme.red)
        .accessibilityIdentifier("AddToWatchlistSwipeAction")
    }

    func getGenres(genreIDs: [Int]?) -> [Genre]? {
        guard let genreIDs else { return nil }
        return homeVM.getGenresForMediaType(for: media.mediaType, genreIDs: genreIDs)
    }
}

struct FriendRowView_Previews: PreviewProvider {
    static var previews: some View {
        FriendRowView(media: dev.mediaMock.first!, friendName: "Steve")
            .previewLayout(.sizeThatFits)
            .environmentObject(dev.homeVM)
    }
}
