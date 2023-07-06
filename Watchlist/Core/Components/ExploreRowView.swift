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

    @State private var showDetailView = false

    var dateConvertedToYear: String {
        if let title = media.mediaType == .tv ? media.firstAirDate : media.releaseDate {
            let date = title.components(separatedBy: "-")
            return date[0]
        }

        return ""
    }

    var body: some View {
        HStack(alignment: .center) {
            if let posterPath = media.posterPath {
                ThumbnailView(imagePath: posterPath, frameHeight: 80)
            }

            centerColumn

            Spacer()

            rightColumn
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showDetailView.toggle()
        }
        .sheet(isPresented: $showDetailView) {
            GeometryReader {
                MediaModalView(media: media, size: $0.size, safeArea: $0.safeAreaInsets)
            }
        }
        .onAppear {
            Task {
                if try await WatchlistManager.shared.doesMediaExistInCollection(media: media) {
                    try await WatchlistManager.shared.setReleaseOrAirDateForMedia(media: media)
                }
                if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: media.id) {
                    media = updatedMedia
                }
            }
        }
    }
}

struct ExploreRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreRowView(media: dev.mediaMock[1], currentTab: .movies)
            .previewLayout(.sizeThatFits)
            .environmentObject(dev.homeVM)
    }
}

extension ExploreRowView {
    var centerColumn: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let title = media.mediaType == .movie ? media.title : media.name {
                Text(title)
                    .font(Font.system(.headline, design: .default))
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color.theme.text)
                    .lineLimit(2)
            }

            if media.mediaType == .tv {
                Text("TV Series")
                    .font(.caption)
                    .foregroundColor(Color.theme.text.opacity(0.6))
            }

            Text(dateConvertedToYear)
                .font(.subheadline)
                .foregroundColor(Color.theme.text.opacity(0.6))
                .fontWeight(.medium)
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
                Task {
                    if !isInMedia(media: media) {
                        try await WatchlistManager.shared.createNewMediaInWatchlist(media: media)
                        AnalyticsManager.shared.logEvent(name: "ExploreTabView_AddMedia")
                    } else {
                        try await WatchlistManager.shared.deleteMediaInWatchlist(media: media)
                        AnalyticsManager.shared.logEvent(name: "ExploreTabView_DeleteMedia")
                    }

                    if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: media.id) {
                        media = updatedMedia
                    }
                }
            }
            .padding(.leading)
    }

    func isInMedia(media: DBMedia) -> Bool {
        let mediaList = homeVM.movieList + homeVM.tvList
        for homeMedia in mediaList where homeMedia.id == media.id {
            return true
        }
        return false
    }

    func getGenres(genreIDs: [Int]?) -> [Genre]? {
        guard let genreIDs else { return nil }
        return homeVM.getGenresForMediaType(for: media.mediaType, genreIDs: genreIDs)
    }
}
