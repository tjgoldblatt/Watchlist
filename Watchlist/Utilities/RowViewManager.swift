//
//  RowViewManager.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/10/23.
//

import Foundation
import SwiftUI

class RowViewManager {
    private var printedError = "[🔥] Bad response from "
    private var homeVM: HomeViewModel
    
    init(homeVM: HomeViewModel) {
        self.homeVM = homeVM
    }
    
    func createRowView(media: Media) -> AnyView {if let mediaType = media.mediaType {
        switch mediaType {
            case .movie:
                return createRowView(movie: media)
            case .tv:
                return createRowView(tvShow: media)
            case .person:
                return AnyView(EmptyView())
        }
    }
        return AnyView(EmptyView())
        
    }
    
    func createRowView(movie: Media) -> AnyView {
        if let voteCount = movie.voteCount, voteCount < 10 {
            printedError += "Movie: \(String(describing: movie.originalTitle)) with \(voteCount) number of votes"
            print(printedError)
            return AnyView(EmptyView())
        }
        
        if let posterPath = movie.posterPath,
//           let posterURL = URL(string: posterPath),
           let overview = movie.overview,
           !overview.isEmpty,
           let voteAverage = movie.voteAverage,
           let genreIDs = movie.genreIDS,
           let title = movie.originalTitle {
            let genres = homeVM.getGenreNames(for: .movie, genreIDs: genreIDs)
            return AnyView(
                RowView(
                    rowContent:
//                        RowContent(
//                            posterPath: posterURL,
//                            title: title,
//                            overview: overview,
//                            rating: voteAverage,
//                            genres: genres
//                        ),
                    MediaDetailContents(
                        posterPath: posterPath,
                        backdropPath: movie.backdropPath,
                        title: title,
                        genres: genres,
                        overview: overview,
                        popularity: movie.popularity,
                        imdbRating: voteAverage,
                        personalRating: nil  // eventually get from homeVM?
                    ),
                    isWatched: true
                )
            )
        }
        return AnyView(EmptyView())
    }
    
    func createRowView(tvShow: Media) -> AnyView {
        if let voteCount = tvShow.voteCount, voteCount < 10 {
            printedError += "TV Show: \(String(describing: tvShow.originalName)) with \(voteCount) number of votes"
            print(printedError)
            return AnyView(EmptyView())
        }
        
        if let posterPath = tvShow.posterPath,
//           let posterURL = URL(string: posterPath),
           let overview = tvShow.overview,
           !overview.isEmpty,
           let voteAverage = tvShow.voteAverage,
           let genreIDs = tvShow.genreIDS,
           let title = tvShow.originalName {
            let genres = homeVM.getGenreNames(for: .tv, genreIDs: genreIDs)
            return AnyView(
                RowView(
                    rowContent:
                        MediaDetailContents(
                            posterPath: posterPath,
                            backdropPath: tvShow.backdropPath,
                            title: title,
                            genres: genres,
                            overview: overview,
                            popularity: tvShow.popularity,
                            imdbRating: voteAverage,
                            personalRating: nil  // eventually get from homeVM?
                        ),
                    isWatched: true
                )
            )
        }
        return AnyView(EmptyView())
    }
}
