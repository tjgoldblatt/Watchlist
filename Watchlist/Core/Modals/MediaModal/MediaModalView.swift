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

    @Namespace private var animation

    @State private var hasUpdatedDetails: Bool = false
    @State private var shouldAddOrDeleteMediaList: Bool?
    @State var isInMediaList: Bool = false
    @State private var showContent: Bool = false
    @State private var expandPoster: Bool = false

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
        _vm = forPreview
            ? StateObject(wrappedValue: MediaModalViewModel(forPreview: true, media: media))
            : StateObject(wrappedValue: MediaModalViewModel(media: media))
    }

    // MARK: - Body

    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    // MARK: - Backdrop

                    BackdropView(size: size, safeArea: safeArea)

                    VStack(spacing: 30) {
                        titleSection

                        overview
                            .opacity(showContent ? 1 : 0)
                            .animation(Animation.spring(response: 0.6, dampingFraction: 0.8).delay(0.5), value: showContent)

                        providers
                            .opacity(showContent ? 1 : 0)
                            .animation(Animation.spring(response: 0.6, dampingFraction: 0.8).delay(0.7), value: showContent)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .overlay(alignment: .top) {
                    Header(size: size, safeArea: safeArea)
                }
            }
            .background(Color.theme.background)
            .coordinateSpace(name: "SCROLL")
            .onAppear {
                isInMediaList = isInMediaList(media: vm.media)
                if homeVM.isMediaIDInWatchlist(for: vm.media.id), hasUpdatedDetails {
                    vm.updateMediaDetails()
                    hasUpdatedDetails = true
                }

                showContent = true
            }
            .dynamicTypeSize(.medium ... .xLarge)
        }
        .overlay {
            if expandPoster,
               let posterPath = vm.media.posterPath
            {
                LazyImage(url: URL(string: TMDBConstants.imageURL + posterPath)) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: "poster", in: animation)
                            .frame(height: 400)
                            .mask {
                                RoundedRectangle(cornerRadius: 10)
                                    .matchedGeometryEffect(id: "poster-corner", in: animation)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.ultraThinMaterial)
                            .onTapGesture {
                                withAnimation(.interactiveSpring()) {
                                    expandPoster = false
                                }
                            }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.width > 30 {
                        dismiss()
                    }
                }
        )
        .onDisappear {
            if shouldAddOrDeleteMediaList == true {
                vm.addToMediaList(isFriendView: friendName != nil, homeVM)
            } else if shouldAddOrDeleteMediaList == false {
                Task { try await WatchlistManager.shared.deleteMediaInWatchlist(media: vm.media) }
            }

            if shouldAddOrDeleteMediaList != false,
               isInMediaList
            {
                vm.updateMedia()
            }
        }
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
                            }
                        }
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
            let progressAmount = 0.9

            HStack {
                if isInMediaList,
                   friendName == nil
                {
                    Menu {
                        Button {
                            vm.media.currentlyWatching.toggle()
                            vm.media.watched = false
                            vm.setMediaCurrentlyWatching(vm.media.currentlyWatching)
                            AnalyticsManager.shared
                                .logEvent(
                                    name: "MediaModalView_ToggleMediaCurrentlyWatching_\(vm.media.currentlyWatching)"
                                )
                        } label: {
                            Text("Mark as Watching")
                            Image(systemName: "play.circle")
                        }

                        if vm.media.currentlyWatching || vm.media.watched || vm.media.personalRating != nil {
                            Button(role: .destructive) {
                                withAnimation(.interactiveSpring()) {
                                    vm.media.watched = false
                                    vm.media.personalRating = nil
                                    vm.media.currentlyWatching = false
                                }
                            } label: {
                                Text("Reset")
                                Image(systemName: "arrow.counterclockwise.circle")
                            }
                            .buttonStyle(.plain)
                        }
                        Button(role: !isInMediaList ? nil : .destructive) {
                            if !isInMediaList {
                                shouldAddOrDeleteMediaList = true
                                isInMediaList = true
                            } else {
                                vm.showDeleteConfirmation.toggle()
                            }
                        } label: {
                            Text(!isInMediaList ? "Add to Watchlist" : "Remove from Watchlist")
                            Image(systemName: !isInMediaList ? "plus" : "xmark")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.theme.text, Color.theme.background)
                            .opacity(-titleProgress < progressAmount ? 1 : 0)
                            .animation(.easeInOut(duration: 0.25), value: -titleProgress < progressAmount)
                    }
                } else {
                    Menu {
                        Button(role: !isInMediaList ? nil : .destructive) {
                            if !isInMediaList {
                                shouldAddOrDeleteMediaList = true
                                isInMediaList = true
                            } else {
                                vm.showDeleteConfirmation.toggle()
                            }
                        } label: {
                            Text(!isInMediaList ? "Add to Watchlist" : "Remove from Watchlist")
                            Image(systemName: !isInMediaList ? "plus" : "xmark")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.theme.text, Color.theme.background)
                            .opacity(-titleProgress < progressAmount ? 1 : 0)
                            .animation(.easeInOut(duration: 0.25), value: -titleProgress < progressAmount)
                    }
                }

                if vm.media.currentlyWatching, isInMediaList {
                    Text("Watching")
                        .font(.footnote)
                        .foregroundColor(Color.theme.genreText)
                        .fontWeight(.bold)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background {
                            ZStack {
                                Capsule()
                                    .foregroundColor(Color.theme.red)
                            }
                        }
                        .opacity(-titleProgress < progressAmount ? 1 : 0)
                        .animation(.easeInOut(duration: 0.25), value: -titleProgress < progressAmount)
                }

                Spacer()

                Button {
                    Task {
                        dismiss()
                    }
                } label: {
                    CloseButton()
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
                        .opacity(-titleProgress > progressAmount ? 1 : 0)
                        .foregroundColor(Color.theme.text)
                        .clipped()
                        .animation(.easeInOut(duration: 0.25), value: -titleProgress > progressAmount)
                }
            }
            .padding(.top, safeArea.top + 20)
            .padding([.horizontal, .bottom], 20)
            .background {
                Color.theme.background.opacity(-progress > 1 ? 1 : 0)
            }
            .offset(y: -minY)
            .confirmationDialog(
                "Are you sure you'd like to delete from your Watchlist?",
                isPresented: $vm.showDeleteConfirmation,
                actions: {
                    Button("Cancel", role: .cancel) { }
                        .buttonStyle(.plain)
                    Button("Delete", role: .destructive) {
                        vm.media.watched = false
                        vm.media.personalRating = nil
                        shouldAddOrDeleteMediaList = false
                        isInMediaList = false
                        AnalyticsManager.shared.logEvent(name: "MediaModalView_DeleteMedia")
                    }
                    .buttonStyle(.plain)
                }
            )
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
            HStack(alignment: .top) {
                // MARK: Title, Genre, Rating, and shit

                VStack(alignment: .leading, spacing: 10) {
                    if let title = vm.media.mediaType == .movie
                        ? vm.media.title ?? vm.media.originalTitle
                        : vm.media.name ?? vm.media.originalName
                    {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.theme.text)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 5)
                            .opacity(showContent ? 1 : 0)
                            .animation(Animation.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showContent)
                    }

                    if (vm.media.releaseDate != nil) || (vm.media.firstAirDate != nil),
                       let genreIds = vm.media.genreIDs, let genre = getGenres(genreIDs: genreIds).first
                    {
                        Text("\(dateConvertedToYear) • \(genre.name.uppercased())")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Color.theme.text.opacity(0.6))
                            .opacity(showContent ? 1 : 0)
                            .animation(Animation.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showContent)
                    }
                    HStack(spacing: 15) {
                        if let voteAverage = vm.media.voteAverage {
                            StarRatingView(rating: voteAverage, size: 17)
                        }

                        rateThisButton

                        Button {
                            if friendName == nil {
                                vm.media.watched.toggle()
                                vm.media.currentlyWatching = false
                                AnalyticsManager.shared.logEvent(name: "MediaModalView_ToggleMediaWatched_\(vm.media.watched)")
                            }
                        } label: {
                            if vm.media.watched {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3.weight(.semibold))
                                    .matchedGeometryEffect(id: "watched", in: animation)
                                    .foregroundStyle(Color.theme.red.gradient)

                            } else {
                                Image(systemName: "checkmark.circle")
                                    .font(.title3.weight(.semibold))
                                    .matchedGeometryEffect(id: "watched", in: animation)
                                    .foregroundStyle(
                                        isInMediaList && friendName == nil
                                            ? Color.theme.red
                                            : Color.theme.secondary
                                    )
                            }
                        }
                        .disabled(!isInMediaList)
                        .disabled(friendName != nil)
                        .animation(.spring(), value: vm.media.watched)
                    }
                    .opacity(showContent ? 1 : 0)
                    .animation(Animation.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: showContent)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.trailing, 110)
        .overlay(alignment: .trailing) {
            if let posterPath = vm.media.posterPath {
                LazyImage(url: URL(string: TMDBConstants.imageURL + posterPath)) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFit()
                            .matchedGeometryEffect(id: "poster", in: animation)
                            .mask {
                                RoundedRectangle(cornerRadius: 10)
                                    .matchedGeometryEffect(id: "poster-corner", in: animation)
                            }
                            .frame(height: 150)
                            .offset(y: -20)
                            .onTapGesture {
                                withAnimation(.interactiveSpring()) {
                                    expandPoster = true
                                }
                            }
                    }
                }
                .opacity(showContent ? 1 : 0)
                .animation(.easeIn.delay(0.3), value: showContent)
            }
        }
    }

    @ViewBuilder
    private var overview: some View {
        if let overview = vm.media.overview {
            ExpandableText(text: overview, lineLimit: 3)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.theme.text)
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
            if let personalRating = vm.media.personalRating {
                StarRatingView(rating: personalRating, size: 17, color: Color.theme.red)
            } else {
                HStack(spacing: 2) {
                    Image(systemName: "star")
                        .font(.system(size: 17))
                        .fontWeight(.bold)
                        .foregroundColor(isInMediaList && friendName == nil ? Color.theme.red : Color.theme.secondary)

                    Text("Rate")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            isInMediaList && friendName == nil
                                ? Color.theme.red
                                : Color.theme.secondary
                        )
                }
            }
        }
        .disabled(friendName != nil)
        .disabled(isInMediaList ? false : true)
        .sheet(isPresented: $vm.showingRating) {
            vm.media.currentlyWatching = false
        } content: {
            RatingModalView(media: $vm.media)
        }
    }

    private var addButton: some View {
        Button {
            if !isInMediaList {
                shouldAddOrDeleteMediaList = true
                isInMediaList = true
            } else {
                vm.showDeleteConfirmation.toggle()
            }
        } label: {
            Text(!isInMediaList ? "Add" : "Added")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(!isInMediaList ? Color.theme.red : Color.theme.genreText)
                .frame(width: 90, height: 35)
                .background(!isInMediaList ? Color.theme.secondary : Color.theme.red)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .fixedSize(horizontal: true, vertical: false)
                .animation(.spring(), value: !isInMediaList)
        }
        .confirmationDialog(
            "Are you sure you'd like to delete from your Watchlist?",
            isPresented: $vm.showDeleteConfirmation,
            actions: {
                Button("Cancel", role: .cancel) { }
                    .buttonStyle(.plain)
                Button("Delete", role: .destructive) {
                    vm.media.watched = false
                    vm.media.personalRating = nil
                    shouldAddOrDeleteMediaList = false
                    isInMediaList = false
                    AnalyticsManager.shared.logEvent(name: "MediaModalView_DeleteMedia")
                }
                .buttonStyle(.plain)
            }
        )
        .frame(width: 100, alignment: .center)
    }

    func isInMediaList(media: DBMedia) -> Bool {
        let mediaList = homeVM.movieList + homeVM.tvList
        for homeMedia in mediaList where homeMedia.id == media.id {
            return true
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
    @State private var isTruncated: Bool?
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
                            isExpanded.toggle()
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
        Group {
            GeometryReader {
                MediaModalView(media: dev.mediaMock[3], forPreview: true, size: $0.size, safeArea: $0.safeAreaInsets)
                    .ignoresSafeArea(.container, edges: .top)
                    .environmentObject(dev.homeVM)
                    .preferredColorScheme(.dark)
            }

            GeometryReader {
                MediaModalView(media: dev.mediaMock[1], forPreview: true, size: $0.size, safeArea: $0.safeAreaInsets)
                    .ignoresSafeArea(.container, edges: .top)
                    .environmentObject(dev.homeVM)
            }
        }
    }
}
