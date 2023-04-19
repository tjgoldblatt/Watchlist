//
//  MediaModalView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/11/23.
//

import SwiftUI

struct MediaModalView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    @StateObject var vm: MediaModalViewModel
    
    init(media: DBMedia) {
     _vm = StateObject(wrappedValue: MediaModalViewModel(media: media))
    }
    
    var body: some View {
        ScrollView {
            backdropSection
            
            VStack(alignment: .leading, spacing: 20) {
                titleSection
                
                ratingSection
                
                overview
            }
            .padding(.horizontal)
        }
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
                        .padding(10)
                        .foregroundColor(Color.theme.genreText)
                        .shadow(color: Color.theme.background.opacity(0.4), radius: 2)
                        .padding()
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

struct MediaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MediaModalView(media: dev.mediaMock.first!)
            .environmentObject(dev.homeVM)
    }
}

extension MediaModalView {
    private var backdropSection: some View {
        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original\(vm.imagePath)")) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? nil : UIScreen.main.bounds.width)
                .frame(maxHeight: 300)
                .clipped()
                .shadow(color: Color.black.opacity(0.3), radius: 5)
        } placeholder: {
            ProgressView()
                .frame(height: 200)
        }
    }
    
    private var genreSection: some View {
        HStack {
            if let genreIds = vm.media.genreIDs {
                GenreSection(genres: getGenres(genreIDs: genreIds))
            } else {
                Spacer()
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let title = vm.media.mediaType == .movie ? vm.media.title : vm.media.name {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.text)
                        .multilineTextAlignment(.leading)
                }
                
                if vm.media.watched {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.theme.red)
                        .imageScale(.large)
                }
            }
            
            genreSection
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
        HStack() {
            addButton
            
            Spacer()
            
            if let voteAverage = vm.media.voteAverage {
                StarRatingView(text: "IMDb RATING", rating: voteAverage, size: 18)
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
        }
        .padding(.horizontal)
    }
    
    private var rateThisButton: some View {
        Button {
            homeVM.hapticFeedback.impactOccurred()
            vm.showingRating.toggle()
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
            homeVM.hapticFeedback.impactOccurred()
            if !isInMedia(media: vm.media) {
                Task {
                    try await WatchlistManager.shared.createNewMediaInWatchlist(media: vm.media)
                    if let updatedMedia = homeVM.getUpdatedMediaFromList(mediaId: vm.media.id) {
                        vm.media = updatedMedia
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
        }
        .alert("Are you sure you'd like to delete from your Watchlist?", isPresented: $vm.showDeleteConfirmation, actions: {
            Button("Delete", role: .destructive) {
                Task {
                    try await WatchlistManager.shared.deleteMediaInWatchlist(media: vm.media)
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
        return homeVM.getGenresForMediaType(for: .tv, genreIDs: genreIDs)
    }
}

struct GenreSection: View {
    @State var genres: [Genre]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(genres) { genre in
                    GenreView(genreName: genre.name, size: 12)
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
            withAnimation(.interactiveSpring()){
                isExpanded.toggle()
            }
        }
        .foregroundColor(Color.theme.red)
        .font(.body)
        .fontWeight(.semibold)
        .buttonStyle(.plain)
    }
}
