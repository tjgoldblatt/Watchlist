//
//  RatingModalView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/22/23.
//

import SwiftUI
import Blackbird

struct RatingModalView: View {
    @Environment(\.blackbirdDatabase) var database
    @Environment(\.dismiss) var dismiss
    
    @State var media: Media
    @State var rating: Int = 0
    
    var tapClosure: () -> Void
    
    var posterPath: String? {
        return media.posterPath
    }
    
    var body: some View {
        ZStack() {
            if let posterPath {
                ZStack {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original\(posterPath)")) { image in
                        image
                            .resizable()
                            .frame(height: UIScreen.main.bounds.height)
                            .scaledToFit()
                            .blur(radius: 40)
                    } placeholder: {
                        Color.theme.background
                    }
                    LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                }
            } else {
                Color.theme.background
            }
            
            VStack(alignment: .center, spacing: 30) {
                if let posterPath {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original\(posterPath)")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300, alignment: .trailing)
                        
                    } placeholder: {
                        Color.theme.background
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
                    
                }
                
                Text("How would you rate \(media.title ?? media.name ?? "this")?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.theme.genreText)
                
                StarsView(rating: $rating)
                    .padding()
                
                Text("Rate")
                    .foregroundColor(Color.theme.text)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 50)
                    .background(Color.theme.secondary)
                    .cornerRadius(10)
                    .onTapGesture {
                        sendRating(rating: rating)
                        tapClosure()
                    }
            }
        }
        .overlay(alignment: .topLeading, content: {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(10)
                    .foregroundColor(Color.theme.genreText)
                    .padding(.top, 40)
                    .padding()
            }
        })
        .ignoresSafeArea(edges: .vertical)
    }
    
    func sendRating(rating: Int) {
        Task {
            if let database, let id = media.id {
                try await MediaModel.update(in: database, set: [\.$personalRating : rating], matching: \.$id == id)
            }
            dismiss()
        }
    }
}

struct RatingModalView_Previews: PreviewProvider {
    static var previews: some View {
        RatingModalView(media: dev.mediaMock.first!) {
            //
        }
    }
}
