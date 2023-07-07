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

    var showSwipeAction = true

    var body: some View {
        HStack(alignment: .center) {
            if let posterPath = media.posterPath {
                ThumbnailView(imagePath: posterPath)
                    .overlay(alignment: .topTrailing) {
                        if homeVM.isMediaIDInWatchlist(for: media.id) {
                            ZStack {
                                Circle()
                                    .fill(Color.theme.background)
                                    .frame(width: 27, height: 27)

                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20)
                                    .foregroundStyle(Color.theme.genreText, Color.theme.red.gradient)
                            }
                            .offset(y: -5)
                        }
                    }
            }

            centerColumn
        }
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .accessibilityIdentifier("FriendRowView")
        .contentShape(Rectangle())
        .onTapGesture(perform: {
            withAnimation {
                showingSheet.toggle()
            }
        })
        .sheet(isPresented: $showingSheet) {
            GeometryReader {
                MediaModalView(media: media, friendName: friendName, size: $0.size, safeArea: $0.safeAreaInsets)
                    .ignoresSafeArea(.container, edges: .top)
            }
        }
        .swipeActions(edge: .trailing) {
            if showSwipeAction {
                if !homeVM.isMediaIDInWatchlist(for: media.id) {
                    swipeActionToAddToWatchlist
                } else {
                    swipeActionToRemoveFromWatchlist
                }
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
                    .lineLimit(1)
                    .frame(alignment: .top)
                    .padding(.bottom, 1)
                    .frame(maxHeight: .infinity)
            }

            Text(media.overview ?? "")
                .font(.system(.caption, design: .default))
                .fixedSize(horizontal: false, vertical: true)
                .fontWeight(.light)
                .foregroundColor(Color.theme.text)
                .lineLimit(3)
                .frame(maxHeight: .infinity)

            HStack {
                if let voteAverage = media.voteAverage {
                    StarRatingView(rating: voteAverage, color: .yellow)
                }

                if let rating = media.personalRating {
                    StarRatingView(rating: rating, color: Color.theme.red)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .multilineTextAlignment(.leading)
        .frame(maxHeight: 110, alignment: .top)
        .frame(minWidth: 50)
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
