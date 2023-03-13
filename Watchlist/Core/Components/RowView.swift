//
//  RowView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI
import TMDb

struct RowView: View {
    
    @State var rowContent: MediaDetailContents
    
    @State var isWatched: Bool
    
    @State private var showingSheet = false
    
    var body: some View {
        HStack(alignment: .center) {
            ThumbnailView(imagePath: "\(rowContent.posterPath)")

            centerColumn
        
            rightColumn
        }
        .frame(maxWidth: .infinity)
        .padding()
        .onTapGesture {
            showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet) {
            MediaDetailView(mediaDetails: rowContent)
        }
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        RowView(rowContent: dev.rowContent, isWatched: true)
            .previewLayout(.sizeThatFits)
    }
}

extension RowView {
    var centerColumn: some View {
        VStack(alignment: .leading) {
            Text(rowContent.title)
                .font(Font.system(.headline, design: .default))
                .fontWeight(.bold)
                .foregroundColor(Color.theme.text)
                .lineLimit(2)
                .frame(alignment: .top)
            
            Text(rowContent.overview)
                .font(.system(size: 10, design: .default))
                .fontWeight(.light)
                .foregroundColor(Color.theme.text)
                .lineLimit(rowContent.genres != nil ? 3 : 5)
            
            
            if let genres = rowContent.genres {
                LazyVGrid(columns:
                            [GridItem(.adaptive(minimum: 50, maximum: 150), spacing: 1), GridItem(.adaptive(minimum: 50, maximum: 150), spacing: 1)], alignment: .leading) {
                    
                    ForEach(Array(zip(genres.indices, genres)), id: \.0) { idx, genre in
                        if idx < 2 {
                            GenreView(genreName: genre.name)
                                
                        }
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxHeight: 115)
        .frame(minWidth: 50)
        .padding(.trailing)
    }
    
    var rightColumn: some View {
        VStack(spacing: 10) {
            StarRatingView(text: "IMDb RATING", rating: rowContent.imdbRating)
            
            
            // TODO: Store personal rating
            //                if let rating = personalRating {
            StarRatingView(text: "YOUR RATING", rating: 8)
            //                }
            
            if isWatched {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color.theme.red)
                    .imageScale(.large)
            }
        }
    }
}

struct RowContent {
    var posterPath: URL
    var title: String
    var overview: String
    var rating: Double
    var genres: [Genre]?
}

struct ThumbnailView: View {
    @State var imagePath: String
    var body: some View {
        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(imagePath)")) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                    
                )
                .frame(width: 75, height: 120)
                .padding(.trailing, 5)
        } placeholder: {
            ProgressView()
        }
    }
}
