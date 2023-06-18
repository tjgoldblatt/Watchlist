//
//  RatingModalView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/22/23.
//

import FirebaseAnalyticsSwift
import NukeUI
import SwiftUI

struct RatingModalView: View {
    @EnvironmentObject var homeVM: HomeViewModel
    @Environment(\.dismiss) var dismiss

    @Binding var media: DBMedia
    @State private var rating: Int = 0

    @Namespace private var animation

    var posterPath: String? {
        return media.posterPath
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                if let posterPath {
                    ZStack {
                        Color.black.ignoresSafeArea()

                        LazyImage(url: URL(string: TMDBConstants.imageURL + posterPath)) { state in
                            if let image = state.image {
                                image
                                    .resizable()
                                    .frame(width: geo.size.width)
                                    .scaledToFit()
                                    .blur(radius: 20)
                            } else {
                                Color.black
                            }
                        }

                        LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                    }
                    .frame(maxWidth: geo.size.width)
                    .ignoresSafeArea()
                } else {
                    Color.theme.background
                }

                VStack(alignment: .center) {
                    if let posterPath {
                        LazyImage(url: URL(string: TMDBConstants.imageURL + posterPath)) { state in
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
                            rating > 0
                                ? ZStack {
                                    Color.black.opacity(0.8)

                                    Text(rating.description)
                                        .font(.system(size: 100))
                                        .fontWeight(.medium)
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
                        .multilineTextAlignment(.center)
                        .padding()

                    StarsView(rating: $rating.animation(.easeInOut))
                        .padding()
                        .accessibilityIdentifier("StarRatingInModal")
                        .dynamicTypeSize(.medium)

                    Button {
                        if rating > 0 { media.watched = true
                            media.personalRating = Double(rating)
                            dismiss()
                            AnalyticsManager.shared.logEvent(name: "RatingModalView_RatingSent")
                        }
                    } label: {
                        Text("Rate")
                            .foregroundColor(rating == 0 ? Color.theme.red : Color.theme.genreText)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(rating == 0 ? Color.theme.secondary : Color.theme.red)
                            .cornerRadius(10)
                    }
                    .disabled(rating == 0)
                    .accessibilityIdentifier("RateButton")
                    .padding()
                }
                .frame(maxWidth: geo.size.width - 50)
                .padding(.bottom)
            }
            .frame(maxWidth: geo.size.width, maxHeight: .infinity)
            .overlay(alignment: .topTrailing) {
                CloseButton()
                    .padding(10)
                    .padding()
            }
            .ignoresSafeArea(edges: .vertical)
            .accessibilityIdentifier("RatingModalView")
        }
        .animation(.spring(), value: rating == 0)
        .analyticsScreen(name: "RatingModalView")
        .dynamicTypeSize(.medium ... .xLarge)
    }
}

struct RatingModalView_Previews: PreviewProvider {
    static var previews: some View {
        RatingModalView(media: .constant(dev.mediaMock.first!))
    }
}

struct CloseButton: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var homeVM: HomeViewModel

    var image = "xmark.circle.fill"

    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundStyle(Color.theme.text, Color.theme.background)
                .fontWeight(.semibold)
                .accessibility(label: Text("Close"))
                .accessibility(hint: Text("Tap to close the screen"))
                .accessibility(addTraits: .isButton)
                .accessibility(removeTraits: .isImage)
        }
    }
}
