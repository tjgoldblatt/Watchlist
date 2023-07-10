//
//  RowView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import Nuke
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
                    .frame(maxHeight: .infinity)
            }

            if let overview = media.overview {
                Text(overview)
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(Color.theme.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(3)
                    .frame(maxHeight: .infinity)
            }

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

    private let pipeline = ImagePipeline {
        $0.dataLoader = DataLoader(configuration: {
            // Disable disk caching built into URLSession
            let conf = DataLoader.defaultConfiguration
            conf.urlCache = nil
            return conf
        }())

        $0.imageCache = ImageCache()
        $0.dataCache = try? DataCache(name: "com.tgoldblatt.watchlist")
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
                Color.gray.opacity(0.2)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .pipeline(pipeline)
        .frame(width: frameWidth, height: frameHeight)
        .padding(.trailing, 5)
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        MovieTabView()
            .environmentObject(dev.homeVM)
            .preferredColorScheme(.dark)

        RowView(media: dev.mediaMock[1])
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .environmentObject(dev.homeVM)
            .padding()
    }
}
