//
//  WatchlistApp.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/8/23.
//

import SwiftUI
import Firebase
import Blackbird

@main
struct WatchlistApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    @StateObject private var vm = HomeViewModel()
    @StateObject private var authVM = AuthenticationViewModel()
    
    var database: Blackbird.Database = try! Blackbird.Database(path: "\(FileManager.default.temporaryDirectory.path)/watchlist-testapp.sqlite"/*, options: [.debugPrintEveryQuery, .debugPrintEveryReportedChange, .debugPrintQueryParameterValues]*/)
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .toolbar(.hidden)
                .environmentObject(vm)
                .environmentObject(authVM)
                .environment(\.blackbirdDatabase, database)
                .onAppear {
                    Task {
                        if Auth.auth().currentUser == nil {
                            do {
                                try await authVM.signInAnonymous()
                            } catch {
                                print(error)
                            }
                        }
                        
                        // Not really sure why we need to save fake data on load for db to save everything 🤷‍♂️
                        // ** Remeber if we change the database this needs to be updated and path of db needs to be updated as well **
                        database.saveMedia(media: Media(mediaType: .movie, id: 1, originalTitle: "", originalName: "", overview: nil, voteAverage: nil, voteCount: nil, posterPath: nil, backdropPath: nil, genreIDS: nil, popularity: nil, firstAirDate: nil, originCountry: nil, originalLanguage: nil, name: nil, adult: nil, releaseDate: nil, title: nil, video: nil, profilePath: nil, knownFor: nil))
                    }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
