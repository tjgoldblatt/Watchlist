//
//  WatchlistApp.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/8/23.
//

import SwiftUI
import Blackbird
import SQLite
import CloudKit

@main
struct WatchlistApp: App {
    
//    init() {
//        do {
//            let sqlDB = WatchlistDataStore.shared
//            WatchlistDataStore.shared.getAllTasks()
//            if let path = sqlDB.dbPath {
//                database = try Blackbird.Database(path: path)
//            }
////            database = try Blackbird.Database(path: "\(getDocumentsDirectory())/WatchlistDB/blackbird-watchlist.sqlite", options: [.debugPrintEveryQuery, .debugPrintEveryReportedChange, .debugPrintQueryParameterValues])
//        } catch let error {
//            print("[💣] Failed to get Database. \(error)")
//        }
//    }
    
    @StateObject private var vm = HomeViewModel()
//    var database: Blackbird.Database = try! Blackbird.Database.inMemoryDatabase()

//    static let fileURL = try! FileManager.default
//        .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        .appendingPathComponent("blackbird-swiftui-test.sqlite")
//    static let fileURL = try! FileManager.default
//        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        .appendingPathComponent("blackbird-swiftui-test.sqlite")
//    let directory = NSPersistentContainer.defaultDirectoryURL()
//    let url = directory.appendingPathComponent(yourModel + ".sqlite")
    
    var database: Blackbird.Database = try! Blackbird.Database(path: "\(FileManager.default.temporaryDirectory.path)/watchlist-testdb.sqlite", options: [.debugPrintEveryQuery, .debugPrintEveryReportedChange, .debugPrintQueryParameterValues])
    
    var firstPost = Post(id: 1, watched: false, mediaType: "movie", media: Data())
    
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
                    print("DB path: \(database.path ?? "in-memory")")
//                    for _ in 0..<5 {
                    if let data = vm.encodeData(
                        with:
                            Media(mediaType: .movie, id: Int.random(in: 0..<1000), originalTitle: "TJ", originalName: "TJ", overview: nil, voteAverage: nil, voteCount: nil, posterPath: nil, backdropPath: nil, genreIDS: nil, popularity: nil, firstAirDate: nil, originCountry: nil, originalLanguage: nil, name: nil, adult: nil, releaseDate: nil, title: nil, video: nil, profilePath: nil, knownFor: nil)
                    ) {
                        try! await Post(id: Int.random(in: 0..<1000), watched: false, mediaType: "movie", media: data)
                            .write(to: database)
                        //                    }
                    }
                }
            }
        }
    }
    
    static func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
}
