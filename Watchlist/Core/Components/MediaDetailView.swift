//
//  MediaDetailView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/11/23.
//

import SwiftUI
import Blackbird

struct MediaDetailView: View {
    @Environment(\.blackbirdDatabase) var database
    
    @State var mediaDetails: MediaDetailContents
    
    @State var media: Media
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    @Environment(\.dismiss) var dismiss
    
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
        .ignoresSafeArea(edges: .top)
    }
}

struct MediaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MediaDetailView(mediaDetails: dev.rowContent, media: dev.mediaMock.first!)
    }
}

extension MediaDetailView {
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
            Text(mediaDetails.title)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(Color.theme.text)
                .multilineTextAlignment(.leading)
            
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
            
            if let personalRating = mediaDetails.personalRating {
                StarRatingView(text: "PERSONAL RATING", rating: personalRating, size: 18)
            } else {
                rateThisButton
                
            }
        }
    }
    
    private var rateThisButton: some View {
        Button {
            print("Rate this tapped")
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
    }
    
    private var addButton: some View {
        Button {
            print(!(homeVM.tvWatchList + homeVM.movieWatchList).contains(media) ? "Add tapped" : "Added")
            Task {
                if let db = database, let id = media.id, let mediaType = media.mediaType, let data = homeVM.encodeData(with: media) {
                    try? await Post(id: id, watched: false, mediaType: mediaType.rawValue, media: data).write(to: db)
                }
                print("Added \(media) to database")
            }
        } label: {
            Text(!(homeVM.tvWatchList + homeVM.movieWatchList).contains(media) ? "Add" : "Added")
                .font(.system(size: 18))
                .fontWeight(.medium)
                .foregroundColor(!(homeVM.tvWatchList + homeVM.movieWatchList).contains(media) ? Color.theme.red : Color.theme.genreText)
                .padding(.vertical, 5)
                .padding(.horizontal)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(!(homeVM.tvWatchList + homeVM.movieWatchList).contains(media) ? Color.theme.secondary.opacity(0.5) : Color.theme.red)
                }
        }

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


