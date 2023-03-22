//
//  RowView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI
import Blackbird

struct RowView: View {
    @Environment(\.blackbirdDatabase) var database
    
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
                    if let db = database, let id = media.id {
                        
                        try? await Post.update(in: db, set: [\.watched : true], matching: \.$id == id)
                        print("Set \(media) to watched")
                    }
                }
            } label: {
                Image(systemName: "film.stack")
            }
            .tint(Color.theme.secondary)
            
            Button(role: .destructive) {
                print("Deleting \(media)")
                if let db = database, let id = media.id {
                    Task {
                        let post = try? await Post.read(from: db, id: id)
                        try? await post?.delete(from: db)
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
                if let db = database, let id = media.id, let mediaType = media.mediaType, let data = homeVM.encodeData(with: media) {
//                    print("DB path: \(db.path!)")
                    try! await Post(id: id, watched: false, mediaType: mediaType.rawValue, media: data).write(to: db)
                    print("Added: \(media.title ?? media.name ?? "")")
                }
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
