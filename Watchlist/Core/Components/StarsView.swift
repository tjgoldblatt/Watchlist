//
//  RatingView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/22/23.
//

import SwiftUI

struct StarsView: View {
    @EnvironmentObject private var homeVM: HomeViewModel
    
    @Binding var rating: Int
    
    var body: some View {
        ZStack {
            starsView
                .overlay(overlayView.mask(starsView))
                .padding()
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
                    .foregroundColor(rating >= index ? Color.theme.red : Color.theme.red.opacity(0.3))
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
            .previewLayout(.sizeThatFits)
    }
}
