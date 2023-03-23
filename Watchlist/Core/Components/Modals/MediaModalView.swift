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
    
    var ratingClosure: () -> Void
    
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
                
                Divider()
                
                overview
            }
            .padding(.horizontal)
        }
        .overlay(alignment: .topLeading, content: {
            Button {
                dismiss()
                ratingClosure()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .padding(10)
                    .foregroundColor(Color.theme.text)
                    .background(Color.theme.background)
                    .cornerRadius(10)
                    .shadow(radius: 4)
                    .padding(.top)
                    .padding()
            }
        })
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
        MediaModalView(mediaDetails: dev.rowContent, media: dev.mediaMock.first!) {
            //
        }
    }
}

extension MediaModalView {
    private var backdropSection: some View {
        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(imagePath)")) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? nil : UIScreen.main.bounds.width)
                .frame(maxHeight: 300)
                .clipped()
            
            
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
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.theme.red)
                        .imageScale(.large)
                        .padding(.horizontal)
                }
            }
            
            genreSection
            
        }
    }
    
    private var overview: some View {
        Text(mediaDetails.overview)
            .font(.body)
            .foregroundColor(Color.theme.text)
            .multilineTextAlignment(.leading)
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
            }
        }
    }
    
    private var rateThisButton: some View {
        Button {
            showingRating.toggle()
        } label: {
            VStack {
                Image(systemName: "star")
                    .font(.system(size: 18))
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.red)
                Text("Rate This")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.red)
            }
        }
        .fullScreenCover(isPresented: $showingRating) {
            RatingModalView(media: media) {
                Task {
                    await database?.fetchPersonalRating(media: media, completionHandler: { rating in
                        personalRating = rating
                    })
                }
            }
        }
    }
    
    private var addButton: some View {
        Button {
            if !isInMedia(mediaModels: mediaList.results, media: media) {
                database?.saveMedia(media: media)
            } else {
                database?.deleteMedia(media: media)
            }
        } label: {
            Text(!isInMedia(mediaModels: mediaList.results, media: media) ? "Add" : "Added")
                .font(.system(size: 18))
                .fontWeight(.medium)
                .foregroundColor(!isInMedia(mediaModels: mediaList.results, media: media) ? Color.theme.red : Color.theme.genreText)
                .padding(.vertical, 5)
                .padding(.horizontal)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(!isInMedia(mediaModels: mediaList.results, media: media) ? Color.theme.secondary.opacity(0.5) : Color.theme.red)
                }
        }
        
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

