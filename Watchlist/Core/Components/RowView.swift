//
//  RowView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import NukeUI
import SwiftUI

struct RowView: View {
    @EnvironmentObject var homeVM: HomeViewModel

    @State var personalRating: Double?

    @State var isWatched: Bool = false

    @State var media: DBMedia

    @State private var showingSheet = false

    @State private var showRatingSheet = false

    var showSwipeAction = true

    var body: some View {
        HStack(alignment: .center) {
            if let posterPath = media.posterPath {
                ThumbnailView(imagePath: posterPath)
            }

            centerColumn

            rightColumn
        }
        .onTapGesture {
            withAnimation {
                showingSheet.toggle()
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .accessibilityIdentifier("RowView")
        .contentShape(Rectangle())
        .sheet(isPresented: $showRatingSheet) {
            Task {
                try? await WatchlistManager.shared.setPersonalRatingForMedia(media: media, personalRating: media.personalRating)
                try? await WatchlistManager.shared.setMediaWatched(media: media, watched: media.personalRating != nil)
                if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: media.id) {
                    media = updatedMedia
                }
            }
        } content: {
            RatingModalView(media: $media)
        }
        .sheet(isPresented: $showingSheet, content: {
            GeometryReader {
                MediaModalView(media: media, size: $0.size, safeArea: $0.safeAreaInsets)
                    .ignoresSafeArea(.container, edges: .top)
            }
        })
        .swipeActions(edge: .trailing) {
            if !isWatched, showSwipeAction {
                swipeActionToSetWatched
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: media.id) {
                    media = updatedMedia
                }
            }
        }
        .onDisappear {
            if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: media.id) {
                media = updatedMedia
            }
        }
        .onReceive(media.mediaType == .movie ? homeVM.$movieList : homeVM.$tvList) { updatedList in
            if let updatedMedia = updatedList.first(where: { $0.id == media.id }) {
                media = updatedMedia
            }
        }
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
                    .lineLimit(1)
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
                ViewThatFits {
                    HStack {
                        ForEach(Array(zip(genres.indices, genres)), id: \.0) { idx, genre in
                            if idx < 2 {
                                GenreView(genreName: genre.name)
                            }
                        }
                    }

                    HStack {
                        ForEach(Array(zip(genres.indices, genres)), id: \.0) { idx, genre in
                            if idx < 1 {
                                GenreView(genreName: genre.name)
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxHeight: 110, alignment: .top)
        .frame(minWidth: 50)
    }

    var rightColumn: some View {
        VStack(alignment: .center, spacing: 20) {
            if let voteAverage = media.voteAverage {
                StarRatingView(text: "IMDb RATING", rating: voteAverage)
            }

            if let rating = media.personalRating {
                StarRatingView(text: "YOUR RATING", rating: rating)
            }
        }
    }

    private var swipeActionToSetWatched: some View {
        Button {
            if personalRating == nil {
                showRatingSheet = true
            }
            AnalyticsManager.shared.logEvent(name: "RowView_SwipeAction")
        } label: {
            Image(systemName: "checkmark.circle")
        }
        .tint(Color.theme.secondary)
        .accessibilityIdentifier("MediaSwipeAction")
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
        LazyImage(url: URL(string: TMDBConstants.imageURL + imagePath)) { state in
            if let image = state.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.theme.secondary)
                    .overlay(alignment: .center) {
                        ProgressView()
                            .foregroundColor(Color.theme.text)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: frameWidth / 2)
                            .offset(x: -2)
                    }
            }
        }
        .frame(width: frameWidth, height: frameHeight)
        .padding(.trailing, 5)
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        MovieTabView()
            .environmentObject(dev.homeVM)

        RowView(media: dev.mediaMock[1])
            .previewLayout(.sizeThatFits)
            .environmentObject(dev.homeVM)
            .padding()
    }
}
