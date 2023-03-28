//
//  ExploreRowView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/27/23.
//

import SwiftUI
import Blackbird

struct ExploreRowView: View {
    @Environment(\.blackbirdDatabase) var database
    @EnvironmentObject var homeVM: HomeViewModel
    
    @State var rowContent: MediaDetailContents
    
    @BlackbirdLiveModels({ try await MediaModel.read(from: $0) }) var mediaList
    
    @State var personalRating: Double?
    
    @State var isWatched: Bool = false
    
    @State var media: Media
    
    @State var currentTab: Tab
    
    @State private var showingSheet = false
    
    @State var addedToWatchlist: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            ThumbnailView(imagePath: "\(rowContent.posterPath)", frameHeight: 70)
            
            centerColumn
            
            Spacer()
            
            rightColumn
        }
        .onTapGesture {
            showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet) {
            MediaModalView(mediaDetails: rowContent, media: media) {
                Task {
                    await database?.fetchPersonalRating(media: media) { rating in
                        personalRating = rating
                    }
                }
            }
            .interactiveDismissDisabled()
        }
        .onAppear {
            Task {
                await database?.fetchIsWatched(media: media) { watched in
                    isWatched = watched
                }
                await database?.fetchPersonalRating(media: media) { rating in
                    personalRating = rating
                }
            }
        }
    }
}

struct ExploreRowView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreRowView(rowContent: dev.rowContent, media: dev.mediaMock.first!, currentTab: .movies)
            .previewLayout(.sizeThatFits)
            .environmentObject(dev.homeVM)
    }
}

extension ExploreRowView {
    
    var centerColumn: some View {
        VStack(alignment: .leading) {
            Text(rowContent.title)
                .font(Font.system(.headline, design: .default))
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color.theme.text)
                .lineLimit(2)
                .frame(alignment: .top)
            
            if let genres = rowContent.genres {
                HStack {
                    ForEach(Array(zip(genres.indices, genres)), id: \.0) { idx, genre in
                        if idx < 2 {
                            GenreView(genreName: genre.name)
                        }
                    }
                }
            }
        }
    }
        
    var rightColumn: some View {
        Text(!isInMedia(mediaModels: mediaList.results, media: media) ? "Add" : "Added")
            .foregroundColor(Color.theme.genreText)
            .font(.subheadline)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(!isInMedia(mediaModels: mediaList.results, media: media) ? Color.theme.secondary : Color.theme.red)
                    .frame(width: 80, height: 30)
            }
            .onTapGesture {
                if !isInMedia(mediaModels: mediaList.results, media: media) {
                    database?.saveMedia(media: media)
                } else {
                    database?.deleteMedia(media: media)
                }
            }
            .frame(maxWidth: 80, alignment: .center)
    }
    
    func isInMedia(mediaModels: [MediaModel], media: Media) -> Bool {
        for mediaModel in mediaModels {
            if let decodedMedia = homeVM.decodeData(with: mediaModel.media) {
                if decodedMedia.id == media.id {
                    return true
                }
            }
        }
        return false
    }
}

