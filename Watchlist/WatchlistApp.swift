//
//  WatchlistApp.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/8/23.
//

import SwiftUI
import Blackbird

@main
struct WatchlistApp: App {
    
    @StateObject private var vm = HomeViewModel()
    
    var database: Blackbird.Database = try! Blackbird.Database(path: "\(FileManager.default.temporaryDirectory.path)/watchlist-testapp.sqlite"/*, options: [.debugPrintEveryQuery, .debugPrintEveryReportedChange, .debugPrintQueryParameterValues]*/)
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .toolbar(.hidden)
            }
            .environmentObject(vm)
            .environment(\.blackbirdDatabase, database)
            .onAppear {
                Task {
                    // Not really sure why we need to save fake data on load for db to save everything 🤷‍♂️
                    // ** Remeber if we change the database this needs to be updated and path of db needs to be updated as well **
                    database.saveMedia(media: Media(mediaType: .movie, id: 1, originalTitle: "", originalName: "", overview: nil, voteAverage: nil, voteCount: nil, posterPath: nil, backdropPath: nil, genreIDS: nil, popularity: nil, firstAirDate: nil, originCountry: nil, originalLanguage: nil, name: nil, adult: nil, releaseDate: nil, title: nil, video: nil, profilePath: nil, knownFor: nil))
                }
            }
        }
    }
}
