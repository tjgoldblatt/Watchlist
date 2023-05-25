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
    @EnvironmentObject var homeVM: HomeViewModel
    @StateObject var vm: MediaModalViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - Computed Vars

    var formattedFriendName: String? {
        if let friendName {
            return "\(friendName.uppercased())'s"
        } else {
            return nil
        }
    }

    var dateConvertedToYear: String {
        if let title = vm.media.mediaType == .tv ? vm.media.firstAirDate : vm.media.releaseDate {
            let date = title.components(separatedBy: "-")
            return date[0]
        }

        return ""
    }

    // MARK: - Init

    var friendName: String?
    var safeArea: EdgeInsets
    var size: CGSize

    init(media: DBMedia, forPreview: Bool = false, friendName: String? = nil, size: CGSize, safeArea: EdgeInsets) {
        self.size = size
        self.safeArea = safeArea
        self.friendName = friendName
        _vm = forPreview ? StateObject(wrappedValue: MediaModalViewModel(forPreview: true, media: media)) : StateObject(wrappedValue: MediaModalViewModel(media: media))
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                // MARK: - Backdrop

                BackdropView(size: size, safeArea: safeArea)

                VStack(spacing: 30) {
                    titleSection

                    ratingSection

                    overview

                    providers
                }
                .padding(.horizontal)
            }
            .overlay(alignment: .top) {
                Header(size: size, safeArea: safeArea)
            }
        }
        .background(Color.theme.background)
        .coordinateSpace(name: "SCROLL")
        .onAppear {
            if homeVM.isMediaIDInWatchlist(for: vm.media.id) {
                vm.updateMediaDetails()
            }
        }
        .dynamicTypeSize(.medium ... .xLarge)
    }

    @ViewBuilder
    func BackdropView(size: CGSize, safeArea: EdgeInsets) -> some View {
        let height = size.height * 0.40
        GeometryReader { proxy in
            let size = proxy.size
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.8))

            LazyImage(url: URL(string: TMDBConstants.imageURL + vm.imagePath)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height + (minY > 0 ? minY : 0), alignment: .center)
                        .clipped()
                        .overlay {
                            ZStack(alignment: .bottom) {
                                // MARK: - Gradient Overlay

                                Rectangle()
                                    .fill(
                                        .linearGradient(colors: [
                                            Color.theme.background.opacity(0 - progress),
                                            Color.theme.background.opacity(0.1 - progress),
                                            Color.theme.background.opacity(0.3 - progress),
                                            Color.theme.background.opacity(0.5 - progress),
                                            Color.theme.background.opacity(0.8 - progress),
                                            Color.theme.background.opacity(1),
                                        ], startPoint: .top, endPoint: .bottom)
                                    )
                                    .animation(.easeInOut, value: size.height)
                            }
                        }
                        .offset(y: -minY)
                        .animation(.easeInOut, value: size.height)
                } else {
                    ProgressView()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height + (minY > 0 ? minY : 0), alignment: .center)
                        .clipped()
                }
            }
        }
        .frame(height: height + safeArea.top)
    }

    @ViewBuilder
    func Header(size: CGSize, safeArea: EdgeInsets) -> some View {
        GeometryReader { proxy in
            let minY = proxy.frame(in: .named("SCROLL")).minY
            let height = size.height * 0.35
            let progress = minY / (height * (minY > 0 ? 0.5 : 0.8))
            let titleProgress = minY / height

            HStack {
                Button {
                    dismiss()
                } label: {
                    CloseButton()
                }

                Spacer(minLength: 0)

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
            .overlay {
                if let title = vm.media.mediaType == .movie
                    ? vm.media.title ?? vm.media.originalTitle
                    : vm.media.name ?? vm.media.originalName
                {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .offset(y: -titleProgress > 0.85 ? 0 : 45)
                        .foregroundColor(Color.theme.text)
                        .clipped()
                        .animation(.easeInOut(duration: 0.25), value: -titleProgress > 0.85)
                }
            }
            .padding(.top, safeArea.top + 20)
            .padding([.horizontal, .bottom], 20)
            .background {
                Color.theme.background.opacity(-progress > 1 ? 1 : 0)
                    .animation(.easeInOut(duration: 0.25), value: -progress > 1)
            }
            .offset(y: -minY)
        }
        .frame(height: 35)
    }
}

extension MediaModalView {
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
                        .fontWeight(.bold)
                        .foregroundColor(Color.theme.text)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
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
                            .foregroundColor(isInMedia(media: vm.media) && friendName == nil ? Color.theme.red : Color.theme.secondary)
                            .imageScale(.large)
                    }
                }
                .disabled(!isInMedia(media: vm.media))
                .disabled(friendName != nil)
                .animation(.spring(), value: vm.media.watched)
            }
        }
    }

    @ViewBuilder
    private var overview: some View {
        if let overview = vm.media.overview {
            ExpandableText(text: overview, lineLimit: 3)
                .foregroundColor(Color.theme.text)
        }
    }

    private var ratingSection: some View {
        HStack {
            addButton
                .frame(minWidth: 110, maxWidth: .infinity)

            if let voteAverage = vm.media.voteAverage {
                StarRatingView(text: "IMDb RATING", rating: voteAverage, size: 18)
                    .frame(minWidth: 110, maxWidth: .infinity)
            }

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
                }
            }
            .animation(.spring(), value: vm.media.personalRating)
            .frame(minWidth: 110, maxWidth: .infinity)
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
                    .foregroundColor(isInMedia(media: vm.media) && friendName == nil ? Color.theme.red : Color.theme.secondary)
                Text("Rate This")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isInMedia(media: vm.media) && friendName == nil ? Color.theme.red : Color.theme.secondary)
            }
        }
        .disabled(friendName != nil)
        .disabled(isInMedia(media: vm.media) ? false : true)
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
            if !isExpanded {
                Text(text)
                    .lineLimit(lineLimit)
                    .background(calculateTruncation(text: text))
                    .onTapGesture {
                        withAnimation(.interactiveSpring(response: 0.3)) {
                            isExpanded = true
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 10).fill(.clear).matchedGeometryEffect(id: "text", in: animation))

                if isTruncated == true {
                    button
                }
            } else {
                Text(text)
                    .background(calculateTruncation(text: text))
                    .onTapGesture {
                        withAnimation(.interactiveSpring(response: 0.3)) {
                            isExpanded = true
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 10).fill(.clear).matchedGeometryEffect(id: "text", in: animation))

                if isTruncated == true {
                    button
                }
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
            withAnimation(.interactiveSpring()) {
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
        GeometryReader {
            MediaModalView(media: dev.mediaMock[1], forPreview: true, size: $0.size, safeArea: $0.safeAreaInsets)
                .ignoresSafeArea(.container, edges: .top)
                .environmentObject(dev.homeVM)
                .preferredColorScheme(.dark)
        }
    }
}
