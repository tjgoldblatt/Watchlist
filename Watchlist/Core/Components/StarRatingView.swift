//
//  StarRatingView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/11/23.
//

import SwiftUI

struct StarRatingView: View {
    var rating: Double
    var size: CGFloat = 14
    var color: Color = .yellow

    var ratingAsString: String {
        return "\(round(rating * 10) / 10.0)"
    }

    var body: some View {
        if rating > 0 {
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .foregroundStyle(color.gradient)
                    .imageScale(.small)

                Text(ratingAsString)
                    .foregroundStyle(Color.theme.text)
            }
            .font(.system(size: size).bold())
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
        StarRatingView(rating: 2)
    }
}
