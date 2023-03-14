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
    
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State var isWatched: Bool
    
    @State var media: Media
    
    @State var currentTab: Tab
    
    @State private var showingSheet = false
    
    var body: some View {
        HStack(alignment: .center) {
            ThumbnailView(imagePath: "\(rowContent.posterPath)")
            
            centerColumn
            
            rightColumn
        }
        .onTapGesture {
            showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet) {
            MediaDetailView(mediaDetails: rowContent, media: media)
        }
        .swipeActions(edge: .trailing) {
            if currentTab == .search {
                searchSwipeAction
            } else {
                showSwipeAction
            }
        }
    }
}

struct RowView_Previews: PreviewProvider {
    static var previews: some View {
        RowView(rowContent: dev.rowContent, isWatched: true, media: dev.mediaMock.first!, currentTab: .movies)
            .previewLayout(.sizeThatFits)
    }
}

extension RowView {
    var centerColumn: some View {
        VStack(alignment: .leading) {
            Text(rowContent.title)
                .font(Font.system(.headline, design: .default))
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color.theme.text)
                .lineLimit(2)
                .frame(alignment: .top)
                .padding(.bottom, 1)
            
            Text(rowContent.overview)
                .font(.system(size: 10, design: .default))
                .fixedSize(horizontal: false, vertical: true)
                .fontWeight(.light)
                .foregroundColor(Color.theme.text)
                .lineLimit(4)
            
            Spacer()
            
            if let genres = rowContent.genres {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        
                        ForEach(Array(zip(genres.indices, genres)), id: \.0) { idx, genre in
                            GenreView(genreName: genre.name)
                        }
                    }
                }
            }
        }
        
        .frame(maxHeight: 115)
        .frame(minWidth: 50)
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
    
    private var showSwipeAction: some View {
        Group {
            Button {
                print("Marking as watched")
                Task {
                    if let id = media.id {
                        await homeVM.markAsWatched(id:id)
                        print("Set \(media) to watched")
                    }
                }
            } label: {
                Image(systemName: "film.stack")
            }
            .tint(Color.theme.secondary)
            
            Button(role: .destructive) {
                print("Deleting \(media)")
                if let id = media.id {
                    Task {
                        await homeVM.deleteMedia(id: id)
                        print("deleted \(media) with \(id)")
                    }
                }
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
    
    private var searchSwipeAction: some View {
        Button {
            print("adding to watchlist")
            
            Task {
                await homeVM.addToDatabase(media:media)
                print("Added \(String(describing: media.id))")
            }
        } label: {
            Image(systemName: "film.stack")
        }
        .tint(Color.theme.secondary)
    }
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
                .frame(height: 120)
                .padding(.trailing, 5)
        } placeholder: {
            ProgressView()
        }
    }
}
