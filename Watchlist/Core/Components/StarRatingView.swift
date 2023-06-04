//
//  StarRatingView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/11/23.
//

import SwiftUI

struct StarRatingView: View {
    var text: String
    var rating: Double
    var size: CGFloat = 14

    var ratingAsString: String {
        return "\(round(rating * 10) / 10.0)"
    }

    var body: some View {
        if rating > 0 {
            VStack(alignment: .center) {
                Text(text)
                    .font(.caption)
                    .fontWeight(.light)
                    .fixedSize(horizontal: true, vertical: false)
                    .foregroundColor(Color.theme.text)

                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(Color.theme.red)
                        .imageScale(.small)

                    Group {
                        Text(ratingAsString)
                            .font(.system(size: size, design: .default))
                            .fontWeight(.medium)
                        Text("/")
                            .font(.system(size: size - 2, design: .default))
                            .fontWeight(.light)
                        Text("10")
                            .font(.system(size: size - 2, design: .default))
                            .fontWeight(.light)
                    }
                    .foregroundColor(Color.theme.text)
                }
                .fixedSize(horizontal: true, vertical: false)
            }
        } else {
            VStack {
                Text("Unrated".uppercased())
            }
            .font(.caption)
            .fontWeight(.light)
            .fixedSize(horizontal: true, vertical: false)
        }
    }
}

struct StarRatingView_Previews: PreviewProvider {
    static var previews: some View {
        StarRatingView(text: "YOUR RATING", rating: 2)
    }
}
