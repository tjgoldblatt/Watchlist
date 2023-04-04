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
    
    func createRowView(media: Media, tab: Tab) -> AnyView {
        if let mediaType = media.mediaType {
            switch mediaType {
                case .movie:
                    return createRowView(movie: media, tab: tab)
                case .tv:
                    return createRowView(tvShow: media, tab: tab)
                case .person:
                    return AnyView(EmptyView())
            }
        }
        return AnyView(EmptyView())
        
    }
    
    func createRowView(movie: Media, tab: Tab) -> AnyView {
        guard let id = movie.id,
              let posterPath = movie.posterPath,
              let overview = movie.overview,
              !overview.isEmpty,
              let voteAverage = movie.voteAverage,
              let genreIDs = movie.genreIDS,
              let title = movie.originalTitle else {
            printedError += "Movie: \(String(describing: movie.originalTitle))"
            return AnyView(EmptyView())
        }
        
        let genres = homeVM.getGenresForMediaType(for: .movie, genreIDs: genreIDs)
        if tab == .explore {
            return AnyView(
            ExploreRowView(rowContent:
                            MediaDetailContents(
                                id: id,
                                posterPath: posterPath,
                                backdropPath: movie.backdropPath,
                                title: title,
                                genres: genres,
                                overview: overview,
                                popularity: movie.popularity,
                                imdbRating: voteAverage
                            ),
                           media: movie, currentTab: tab))
        } else {
            return AnyView(
                RowView(
                    rowContent:
                        MediaDetailContents(
                            id: id,
                            posterPath: posterPath,
                            backdropPath: movie.backdropPath,
                            title: title,
                            genres: genres,
                            overview: overview,
                            popularity: movie.popularity,
                            imdbRating: voteAverage
                        ), media: movie, currentTab: tab
                )
            )
        }
    }
    
    func createRowView(tvShow: Media, tab: Tab) -> AnyView {
        guard let id = tvShow.id,
              let posterPath = tvShow.posterPath,
              let overview = tvShow.overview,
              !overview.isEmpty,
              let voteAverage = tvShow.voteAverage,
              let genreIDs = tvShow.genreIDS,
              let title = tvShow.originalName else {
            printedError += "TV Show: \(String(describing: tvShow.originalName))"
            return AnyView(EmptyView())
        }
        
        let genres = homeVM.getGenresForMediaType(for: .tv, genreIDs: genreIDs)
        
        
        if tab == .explore {
            return AnyView(
                ExploreRowView(rowContent:
                                MediaDetailContents(
                                    id: id,
                                    posterPath: posterPath,
                                    backdropPath: tvShow.backdropPath,
                                    title: title,
                                    genres: genres,
                                    overview: overview,
                                    popularity: tvShow.popularity,
                                    imdbRating: voteAverage
                                ),
                               media: tvShow, currentTab: tab))
        } else {
            return AnyView(
                RowView(
                    rowContent:
                        MediaDetailContents(
                            id: id,
                            posterPath: posterPath,
                            backdropPath: tvShow.backdropPath,
                            title: title,
                            genres: genres,
                            overview: overview,
                            popularity: tvShow.popularity,
                            imdbRating: voteAverage
                        ), media: tvShow, currentTab: tab
                )
            )
        }
    }
}
