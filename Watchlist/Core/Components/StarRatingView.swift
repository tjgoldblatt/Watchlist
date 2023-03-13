//
//  StarRatingView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/11/23.
//

import SwiftUI

struct StarRatingView: View {
    
    @State var text: String
    @State var rating: Double
    
    var ratingAsString: String {
        return "\(round(rating * 10) / 10.0)"
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text(text)
                .font(.caption)
                .fontWeight(.light)
            
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .foregroundColor(Color.theme.red)
                    .imageScale(.small)
                
                Text(ratingAsString)
                    .font(.system(size: 14, design: .default))
                    .fontWeight(.medium)
                Text("/")
                    .font(.system(size: 12, design: .default))
                    .fontWeight(.light)
                Text("10")
                    .font(.system(size: 12, design: .default))
                    .fontWeight(.light)
            }
        }
    }
}

struct StarRatingView_Previews: PreviewProvider {
    static var previews: some View {
        StarRatingView(text: "YOUR RATING", rating: 7)
    }
}
