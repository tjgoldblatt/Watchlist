//
//  RatingView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/22/23.
//

import SwiftUI
import Blackbird

struct StarsView: View {
    
    @Binding var rating: Int
    
    var body: some View {
        ZStack {
            starsView
                .overlay(overlayView.mask(starsView))
        }
    }
    
    private var overlayView: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.theme.red)
                    .frame(width: CGFloat(rating) / 10 * geo.size.width)
                
            }
        }
        .allowsHitTesting(false)
    }
    
    private var starsView: some View {
        HStack {
            ForEach(1..<11) { index in
                image(for: index)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.secondary)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            rating = index
                        }
                    }
                    .accessibilityIdentifier("Star #\(index)")
            }
        }
    }
    
    func image(for number: Int) -> Image {
        if number > rating {
            return Image(systemName: "star")
        } else {
            return Image(systemName: "star.fill")
        }
    }
}

struct RatingView_Previews: PreviewProvider {
    static var previews: some View {
        StarsView(rating: .constant(1))
    }
}
