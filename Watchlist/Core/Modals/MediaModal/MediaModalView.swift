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
    
    @EnvironmentObject var homeVM: HomeViewModel
    @StateObject var vm: MediaModalViewModel
    
    var dateConvertedToYear: String {
        if let title = vm.media.mediaType == .tv ? vm.media.firstAirDate : vm.media.releaseDate {
            let date = title.components(separatedBy: "-")
            return date[0]
        }
        
        return ""
    }
    
    init(media: DBMedia) {
        _vm = StateObject(wrappedValue: MediaModalViewModel(media: media))
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                backdropSection(geo: geo)
                
                VStack(alignment: .center, spacing: 30) {
                    titleSection
                    
                    ratingSection
                    
                    overview
                }
                .padding(.horizontal)
                .frame(maxWidth: geo.size.width)
            }
            .analyticsScreen(name: "MediaModalView")
            .overlay(alignment: .topLeading) {
                Button {
                    dismiss()
                } label: {
                    CloseButton()
                        .padding()
                }
            }
            .overlay(alignment: .topTrailing) {
                if isInMedia(media: vm.media) && vm.media.watched {
                    Menu {
                        Button(role: .destructive) {
                            AnalyticsManager.shared.logEvent(name: "MediaModalView_ResetMedia")
                            Task {
                                try await WatchlistManager.shared.setPersonalRatingForMedia(media: vm.media, personalRating: nil)
                                try await WatchlistManager.shared.setMediaWatched(media: vm.media, watched: false)
                                if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: vm.media.id) {
                                    vm.media = updatedMedia
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
                            .frame(width: 25, height: 25)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.theme.text, Color.theme.background)
                            .shadow(color: Color.black.opacity(0.4), radius: 2)
                            .padding()
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .onAppear {
                if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: vm.media.id) {
                    vm.media = updatedMedia
                }
            }
        }
        .background(Color.theme.background)
    }
}

extension MediaModalView {
    func backdropSection(geo: GeometryProxy) -> some View {
        LazyImage(url: URL(string: "https://image.tmdb.org/t/p/original\(vm.imagePath)")) { state in
            if let image = state.image {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? nil : geo.size.width)
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
                if let title = vm.media.mediaType == .movie ? vm.media.title : vm.media.name {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.text)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
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
                
                if vm.media.watched {
                    Color.theme.secondary.frame(width: 1, height: 20)

                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.theme.red)
                        .imageScale(.large)
                }
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
                .padding(.trailing)
            
            Spacer()
            
            if let voteAverage = vm.media.voteAverage {
                StarRatingView(text: "IMDb RATING", rating: voteAverage, size: 18)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            Group {
                if let personalRating = vm.media.personalRating {
                    StarRatingView(text: "PERSONAL RATING", rating: personalRating, size: 18)
                } else {
                    rateThisButton
                        .disabled(isInMedia(media: vm.media) ? false : true)
                }
            }
            .frame(minWidth: 110)
            .padding(.leading)
            
            Spacer()
        }
        .padding(.leading)
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
        .sheet(isPresented: $vm.showingRating, onDismiss: {
            if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: vm.media.id) {
                vm.media = updatedMedia
            }
        }) {
            RatingModalView(media: vm.media, shouldShowRatingModal: $vm.showingRating)
        }
    }
    
    private var addButton: some View {
        Button {
            if !isInMedia(media: vm.media) {
                Task {
                    try await WatchlistManager.shared.createNewMediaInWatchlist(media: vm.media)
                    if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: vm.media.id) {
                        vm.media = updatedMedia
                    }
                    AnalyticsManager.shared.logEvent(name: "MediaModalView_AddMedia")
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
        }
        .alert("Are you sure you'd like to delete from your Watchlist?", isPresented: $vm.showDeleteConfirmation, actions: {
            Button("Delete", role: .destructive) {
                Task {
                    try await WatchlistManager.shared.deleteMediaInWatchlist(media: vm.media)
                    AnalyticsManager.shared.logEvent(name: "MediaModalView_DeleteMedia")
                }
            }
            .buttonStyle(.plain)
            Button("Cancel", role: .cancel) {}
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(text)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(calculateTruncation(text: text))
                .onTapGesture {
                    withAnimation(.interactiveSpring()) {
                        isExpanded = true
                    }
                }
            
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
        MediaModalView(media: dev.mediaMock[0])
            .environmentObject(dev.homeVM)
    }
}
