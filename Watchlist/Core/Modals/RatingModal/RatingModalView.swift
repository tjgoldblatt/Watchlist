//
//  RatingModalView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/22/23.
//

import SwiftUI
import NukeUI
import FirebaseAnalyticsSwift

struct RatingModalView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var media: DBMedia
    @State var rating: Int = 0
    
    @Binding var shouldShowRatingModal: Bool
    
    var posterPath: String? {
        return media.posterPath
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                if let posterPath {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        
                        LazyImage(url: URL(string: "https://image.tmdb.org/t/p/original\(posterPath)")) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                    .scaledToFit()
                                    .blur(radius: 20)
                            } else {
                                Color.black
                            }
                        }
                            
                        LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                } else {
                    Color.theme.background
                }
                
                VStack(alignment: .center) {
                    if let posterPath {
                        LazyImage(url: URL(string: "https://image.tmdb.org/t/p/original\(posterPath)")) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 300, alignment: .trailing)
                            } else {
                                Color.theme.background
                                    .frame(width: 200, height: 300)

                            }
                        }
                        .overlay {
                            rating > 0 ?
                            ZStack {
                                Color.black.opacity(0.9)
                                
                                Text("\(rating)")
                                    .font(.system(size: 90))
                                    .fontWeight(.light)
                                    .foregroundColor(Color.theme.genreText)
                            }
                            : nil
                        }
                        .cornerRadius(10)
                        .padding()
                    }
                    Text("How would you rate \(media.title ?? media.name ?? "this")?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.theme.genreText)
                        .padding()
                    
                    StarsView(rating: $rating)
                        .padding()
                        .accessibilityIdentifier("StarRatingInModal")
                    
                    Text("Rate")
                        .foregroundColor(Color.theme.red)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.theme.secondary)
                        .cornerRadius(10)
                        .disabled(rating == 0)
                        .opacity(rating != 0 ? 1 : 0.7)
                        .onTapGesture {
                                Task {
                                    try await WatchlistManager.shared.setPersonalRatingForMedia(media: media, personalRating: Double(rating))
                                    
                                    try await WatchlistManager.shared.setMediaWatched(media: media, watched: true)
                                    
                                    shouldShowRatingModal = false
                                }
                            AnalyticsManager.shared.logEvent(name: "RatingModalView_RatingSent")
                        }
                        .accessibilityIdentifier("RateButton")
                        .padding()
                    
                }
                .frame(maxWidth: geo.size.width - 50)
                .padding(.bottom)
            }
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
            .overlay(alignment: .topLeading) {
                CloseButton()
                    .padding(10)
                    .padding()
            }
            .ignoresSafeArea(edges: .vertical)
            .accessibilityIdentifier("RatingModalView")
        }
        .analyticsScreen(name: "RatingModalView")
    }
}

struct RatingModalView_Previews: PreviewProvider {
    static var previews: some View {
        RatingModalView(media: dev.mediaMock.first!, shouldShowRatingModal: .constant(true))
    }
}

struct CloseButton: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var homeVM: HomeViewModel

    var body: some View {
        Image(systemName: "xmark.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 25, height: 25)
            .foregroundStyle(Color.theme.text, Color.theme.background)
            .fontWeight(.semibold)
            .shadow(color: Color.black.opacity(0.4), radius: 2)
            .accessibility(label:Text("Close"))
            .accessibility(hint:Text("Tap to close the screen"))
            .accessibility(addTraits: .isButton)
            .accessibility(removeTraits: .isImage)
            .onTapGesture {
                dismiss()
            }
    }
}
