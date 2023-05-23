//
//  MediaModalView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/11/23.
//

import FirebaseAnalyticsSwift
import NukeUI
import SwiftUI

struct MediaModalView: View {
    @Environment(\.dismiss) var dismiss

    var friendName: String?

    var formattedFriendName: String? {
        if let friendName {
            return "\(friendName.uppercased())'s"
        } else {
            return nil
        }
    }

    @EnvironmentObject var homeVM: HomeViewModel
    @StateObject var vm: MediaModalViewModel

    var dateConvertedToYear: String {
        if let title = vm.media.mediaType == .tv ? vm.media.firstAirDate : vm.media.releaseDate {
            let date = title.components(separatedBy: "-")
            return date[0]
        }

        return ""
    }

    init(media: DBMedia, forPreview: Bool = false, friendName: String? = nil) {
        self.friendName = friendName
        _vm = forPreview
            ? StateObject(wrappedValue: MediaModalViewModel(forPreview: true))
            : StateObject(wrappedValue: MediaModalViewModel(media: media))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                backdropSection()

                VStack(alignment: .center, spacing: 30) {
                    titleSection

                    ratingSection

                    overview

                    providers
                }
                .padding(.horizontal)
            }
            .analyticsScreen(name: "MediaModalView")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        CloseButton()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    if isInMedia(media: vm.media), vm.media.watched, vm.media.personalRating != nil, friendName == nil {
                        Menu {
                            Button(role: .destructive) {
                                AnalyticsManager.shared.logEvent(name: "MediaModalView_ResetMedia")
                                Task {
                                    try await WatchlistManager.shared.setPersonalRatingForMedia(
                                        media: vm.media,
                                        personalRating: nil)
                                    try await WatchlistManager.shared.setMediaWatched(media: vm.media, watched: false)

                                    withAnimation(.easeInOut) {
                                        if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: vm.media.id) {
                                            vm.media = updatedMedia
                                        }
                                    }
                                }
                            } label: {
                                Text("Reset")
                                Image(systemName: "arrow.counterclockwise.circle")
                            }
                            .buttonStyle(.plain)
                        } label: {
                            Image(systemName: "ellipsis.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.theme.text, Color.theme.background)
                                .shadow(color: Color.black.opacity(0.4), radius: 2)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .onAppear {
                if homeVM.isMediaIDInWatchlist(for: vm.media.id) {
                    vm.updateMediaDetails()
                }
            }
            .background(Color.theme.background)
            .dynamicTypeSize(.medium ... .xLarge)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

extension MediaModalView {
    func backdropSection() -> some View {
        LazyImage(url: URL(string: TMDBConstants.imageURL + vm.imagePath)) { state in
            if let image = state.image {
                image
                    .resizable()
                    .scaledToFill()

                    .frame(maxHeight: 300)
                    .clipped()
                    .shadow(color: Color.black.opacity(0.3), radius: 5)
            } else {
                ProgressView()
                    .frame(height: 200)
            }
        }
    }

    private var genreSection: some View {
        VStack(alignment: .leading) {
            if let genreIds = vm.media.genreIDs {
                GenreSection(genres: getGenres(genreIDs: genreIds))
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .center, spacing: 15) {
            HStack {
                if let title = vm.media.mediaType == .movie
                    ? vm.media.title ?? vm.media.originalTitle
                    : vm.media.name ?? vm.media.originalName
                {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.text)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                }
            }

            HStack(spacing: 15) {
                if (vm.media.releaseDate != nil) || (vm.media.firstAirDate != nil) {
                    Text(dateConvertedToYear)
                        .font(.headline)
                        .foregroundColor(Color.theme.text.opacity(0.6))
                        .fontWeight(.medium)

                    Color.theme.secondary.frame(width: 1, height: 20)
                }

                if let genreIds = vm.media.genreIDs, let genre = getGenres(genreIDs: genreIds).first {
                    Text(genre.name)
                        .font(.headline)
                        .foregroundColor(Color.theme.text.opacity(0.6))
                        .fontWeight(.medium)
                }

                Color.theme.secondary.frame(width: 1, height: 20)

                Button {
                    if friendName == nil {
                        if vm.media.watched {
                            Task {
                                try await WatchlistManager.shared.setMediaWatched(media: vm.media, watched: false)
                            }
                            vm.media.watched = false
                        } else {
                            Task {
                                try await WatchlistManager.shared.setMediaWatched(media: vm.media, watched: true)
                            }
                            vm.media.watched = true
                        }
                        AnalyticsManager.shared.logEvent(name: "MediaModalView_ToggleMediaWatched_\(vm.media.watched)")
                    }
                } label: {
                    if vm.media.watched {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color.theme.red)
                            .imageScale(.large)
                    } else {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(Color.theme.red)
                            .imageScale(.large)
                    }
                }
                .disabled(!isInMedia(media: vm.media))
                .disabled(friendName != nil)
                .animation(.spring(), value: vm.media.watched)
            }
        }
    }

    private var overview: some View {
        if let overview = vm.media.overview {
            return AnyView(ExpandableText(text: overview, lineLimit: 3))
        } else {
            return AnyView(EmptyView())
        }
    }

    private var ratingSection: some View {
        HStack {
            addButton
                .frame(minWidth: 110)

            Spacer()

            if let voteAverage = vm.media.voteAverage {
                StarRatingView(text: "IMDb RATING", rating: voteAverage, size: 18)
                    .frame(minWidth: 110)
            }

            Spacer()

            Group {
                if let personalRating = vm.media.personalRating {
                    StarRatingView(text: "\(formattedFriendName ?? "PERSONAL") RATING", rating: personalRating, size: 18)
                        .onTapGesture {
                            if friendName == nil {
                                vm.showingRating.toggle()
                                AnalyticsManager.shared.logEvent(name: "MediaModalView_PersonalRatingButton_Tapped")
                            }
                        }
                        .disabled(friendName != nil)
                } else {
                    rateThisButton
                        .disabled(isInMedia(media: vm.media) ? false : true)
                }
            }
            .animation(.spring(), value: vm.media.personalRating)
            .frame(minWidth: 110)
            .sheet(isPresented: $vm.showingRating, onDismiss: {
                if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: vm.media.id) {
                    vm.media = updatedMedia
                }
            }) {
                RatingModalView(media: vm.media)
            }
        }
    }

    @ViewBuilder
    private var providers: some View {
        VStack(spacing: 10) {
            if let countryProvider = vm.countryProvider,
               let link = countryProvider.link
            {
                VStack(spacing: 0) {
                    Text("Where To Watch")
                        .foregroundColor(Color.theme.text)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        Text("Brought to you by".uppercased())
                            .fontWeight(.light)
                            .font(.caption2)

                        Image("JustWatch")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        if let stream = countryProvider.flatrate {
                            ForEach(stream, id: \.self) { provider in
                                ProviderView(provider: provider, providerType: "stream", link: link)
                            }
                        }
                        if let free = countryProvider.free {
                            ForEach(free, id: \.self) { provider in
                                ProviderView(provider: provider, providerType: "free", link: link)
                            }
                        }
                        if let ads = countryProvider.ads {
                            ForEach(ads, id: \.self) { provider in
                                ProviderView(provider: provider, providerType: "ads", link: link)
                            }
                        }
                        if let rent = countryProvider.rent {
                            ForEach(rent, id: \.self) { provider in
                                ProviderView(provider: provider, providerType: "rent", link: link)
                            }
                        }
                        if let buy = countryProvider.buy {
                            ForEach(buy, id: \.self) { provider in
                                ProviderView(provider: provider, providerType: "buy", link: link)
                            }
                        }
                    }
                }
            }
        }
        .padding(.bottom)
    }

    private var rateThisButton: some View {
        Button {
            vm.showingRating.toggle()
            AnalyticsManager.shared.logEvent(name: "MediaModalView_RateButton_Tapped")
        } label: {
            VStack {
                Image(systemName: "star")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(isInMedia(media: vm.media) ? Color.theme.red : Color.theme.secondary)
                Text("Rate This")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isInMedia(media: vm.media) ? Color.theme.red : Color.theme.secondary)
            }
        }
    }

    private var addButton: some View {
        Button {
            if !isInMedia(media: vm.media) {
                Task {
                    var mediaToAdd = vm.media
                    if friendName != nil {
                        mediaToAdd.watched = false
                        mediaToAdd.personalRating = nil
                    }

                    try await WatchlistManager.shared.createNewMediaInWatchlist(media: mediaToAdd)
                    if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: vm.media.id),
                       friendName == nil
                    {
                        vm.media = updatedMedia
                    }
                    if friendName == nil {
                        AnalyticsManager.shared.logEvent(name: "MediaModalView_AddMedia")
                    } else {
                        AnalyticsManager.shared.logEvent(name: "FriendMediaModalView_AddMedia")
                    }
                }
            } else {
                vm.showDeleteConfirmation.toggle()
            }
        } label: {
            Text(!isInMedia(media: vm.media) ? "Add" : "Added")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(!isInMedia(media: vm.media) ? Color.theme.red : Color.theme.genreText)
                .frame(width: 90, height: 35)
                .background(!isInMedia(media: vm.media) ? Color.theme.secondary : Color.theme.red)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .fixedSize(horizontal: true, vertical: false)
                .animation(.spring(), value: !isInMedia(media: vm.media))
        }
        .confirmationDialog(
            "Are you sure you'd like to delete from your Watchlist?",
            isPresented: $vm.showDeleteConfirmation,
            actions: {
                Button("Cancel", role: .cancel) { }
                    .buttonStyle(.plain)

                Button("Delete", role: .destructive) {
                    Task {
                        try await WatchlistManager.shared.deleteMediaInWatchlist(media: vm.media)
                        vm.media.watched = false
                        vm.media.personalRating = nil
                        AnalyticsManager.shared.logEvent(name: "MediaModalView_DeleteMedia")
                    }
                }
                .buttonStyle(.plain)
            })
        .frame(width: 100, alignment: .center)
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

    func getGenres(genreIDs: [Int]) -> [Genre] {
        return homeVM.getGenresForMediaType(for: vm.media.mediaType, genreIDs: genreIDs)
    }
}

struct GenreSection: View {
    @State var genres: [Genre]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(genres.indices, id: \.self) { index in
                    if index < 3 {
                        GenreView(genreName: genres[index].name, size: 12)
                    }
                }
            }
        }
    }
}

struct ExpandableText: View {
    let text: String
    let lineLimit: Int

    @State private var isExpanded: Bool = false
    @State private var isTruncated: Bool? = nil
    @Namespace private var animation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(text)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(calculateTruncation(text: text))
                .onTapGesture {
                    withAnimation(.easeOut) {
                        isExpanded = true
                    }
                }
                .background(RoundedRectangle(cornerRadius: 10).fill(.clear).matchedGeometryEffect(id: "text", in: animation))

            if isTruncated == true {
                button
            }
        }
        .multilineTextAlignment(.leading)
        // Re-calculate isTruncated for the new text
        .onChange(of: text, perform: { _ in isTruncated = nil })
    }

    func calculateTruncation(text: String) -> some View {
        // Select the view that fits in the background of the line-limited text.
        ViewThatFits(in: .vertical) {
            Text(text)
                .hidden()
                .onAppear {
                    // If the whole text fits, then isTruncated is set to false and no button is shown.
                    guard isTruncated == nil else { return }
                    isTruncated = false
                }
            Color.clear
                .hidden()
                .onAppear {
                    // If the whole text does not fit, Color.clear is selected,
                    // isTruncated is set to true and button is shown.
                    guard isTruncated == nil else { return }
                    isTruncated = true
                }
        }
    }

    var button: some View {
        Button(isExpanded ? "Less" : "More") {
            withAnimation(.easeInOut) {
                isExpanded.toggle()
            }
        }
        .foregroundColor(Color.theme.red)
        .font(.body)
        .fontWeight(.semibold)
        .buttonStyle(.plain)
    }
}

struct MediaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MediaModalView(media: dev.mediaMock[0], forPreview: true)
                .environmentObject(dev.homeVM)
        }
    }
}
