//
//  MediaModalView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/11/23.
//

import SwiftUI
import Blackbird

struct MediaModalView: View {
    @Environment(\.blackbirdDatabase) var database
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    @BlackbirdLiveModels({ try await MediaModel.read(from: $0) }) var mediaList
    
    @State var mediaDetails: MediaDetailContents
    @State var media: Media
    
    @State var personalRating: Double?
    
    @State var isAdded = false
    @State var isWatched = false
    
    @State private var showingRating = false
    @State private var showDeleConfirmation = false
    
    @State private var selectedOption: String = "Clear Rating"
    let options = ["Clear Rating"]
    
    var imagePath: String {
        if let backdropPath = mediaDetails.backdropPath {
            return backdropPath
        } else {
            return mediaDetails.posterPath
        }
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
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .fontWeight(.semibold)
                    .padding(10)
                    .foregroundColor(Color.theme.genreText)
                    .shadow(color: Color.theme.background.opacity(0.4), radius: 2)
                    .padding()
            }
        }
        .overlay(alignment: .topTrailing) {
            if isInMedia(mediaModels: mediaList.results, media: media) && isWatched {
                Menu {
                    Button(role: .destructive) {
                        Task {
                            await database?.sendRating(rating: nil, media: media)
                            await database?.fetchPersonalRating(media: media) { rating in
                                personalRating = rating
                            }
                            await database?.setWatched(watched: false, media: media)
                            isWatched = false
                        }
                    } label: {
                        Text("Reset")
                        Image(systemName: "arrow.counterclockwise.circle")
                    }
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
        .onAppear {
            Task {
                await database?.fetchPersonalRating(media: media) { rating in
                    personalRating = rating
                }
                
                await database?.fetchIsWatched(media: media, completionHandler: { watched in
                    isWatched = watched
                })
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

struct MediaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MediaModalView(mediaDetails: dev.rowContent, media: dev.mediaMock.first!)
    }
}

extension MediaModalView {
    private var backdropSection: some View {
        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original\(imagePath)")) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? nil : UIScreen.main.bounds.width)
                .frame(maxHeight: 300)
                .clipped()
                .shadow(color: Color.black.opacity(0.3), radius: 5)
        } placeholder: {
            ProgressView()
        }
    }
    
    private var genreSection: some View {
        HStack {
            if let genres = mediaDetails.genres {
                GenreSection(genres: genres)
            } else {
                Spacer()
            }
        }
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(mediaDetails.title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.text)
                    .multilineTextAlignment(.leading)
                
                if isWatched {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.theme.red)
                        .imageScale(.large)
                }
            }
            
            genreSection
        }
    }
    
    private var overview: some View {
        ExpandableText(text: mediaDetails.overview, lineLimit: 3)
    }
    
    private var ratingSection: some View {
        HStack() {
            addButton
            
            Spacer()
            
            StarRatingView(text: "IMDb RATING", rating: mediaDetails.imdbRating, size: 18)
            
            Spacer()
            
            if let personalRating {
                StarRatingView(text: "PERSONAL RATING", rating: personalRating, size: 18)
            } else {
                rateThisButton
                    .disabled(isInMedia(mediaModels: mediaList.results, media: media) ? false : true)
            }
        }
        .padding(.trailing)
    }
    
    private var rateThisButton: some View {
        Button {
            homeVM.hapticFeedback.impactOccurred()
            showingRating.toggle()
        } label: {
            VStack {
                Image(systemName: "star")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(isInMedia(mediaModels: mediaList.results, media: media) ? Color.theme.red : Color.theme.secondary)
                Text("Rate This")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isInMedia(mediaModels: mediaList.results, media: media) ? Color.theme.red : Color.theme.secondary)
            }
        }
        .sheet(isPresented: $showingRating, onDismiss: {
            Task {
                await database?.fetchPersonalRating(media: media) { rating in
                    personalRating = rating
                }
                if personalRating != nil {
                    await database?.setWatched(watched: true, media: media)
                    await database?.fetchIsWatched(media: media) { watched in
                        isWatched = watched
                    }
                }
            }
        }) {
            RatingModalView(media: media)
        }
    }
    
    private var addButton: some View {
        Button {
            homeVM.hapticFeedback.impactOccurred()
            if !isInMedia(mediaModels: mediaList.results, media: media) {
                database?.saveMedia(media: media)
            } else {
                showDeleConfirmation.toggle()
            }
        } label: {
            Text(!isInMedia(mediaModels: mediaList.results, media: media) ? "Add" : "Added")
                .font(.system(size: 18))
                .fontWeight(.medium)
                .foregroundColor(!isInMedia(mediaModels: mediaList.results, media: media) ? Color.theme.red : Color.theme.genreText)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(!isInMedia(mediaModels: mediaList.results, media: media) ? Color.theme.secondary : Color.theme.red)
                        .frame(width: 80, height: 30)
                }
        }
        .alert("Are you sure you'd like to delete from your Watchlist?", isPresented: $showDeleConfirmation, actions: {
            Button("Delete", role: .destructive) { database?.deleteMedia(media: media) }
            Button("Cancel", role: .cancel) {}
        })
        .frame(width: 100, alignment: .center)
        
    }
    
    func isInMedia(mediaModels: [MediaModel], media: Media) -> Bool {
        for mediaModel in mediaModels {
            if let decodedMedia = homeVM.decodeData(with: mediaModel.media) {
                if decodedMedia.id == media.id {
                    return true
                }
            }
        }
        return false
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
        Button(isExpanded ? "" : "More") {
            withAnimation(.interactiveSpring()){
                isExpanded = true
            }
        }
        .foregroundColor(Color.theme.red)
        .font(.body)
        .fontWeight(.semibold)
    }
}
