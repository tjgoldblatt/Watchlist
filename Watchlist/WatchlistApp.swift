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
//            if let path = sqlDB.dbPath {
//                database = try Blackbird.Database(path: path, options: [.debugPrintEveryQuery, .debugPrintEveryReportedChange, .debugPrintQueryParameterValues])
//            }
////            database = try Blackbird.Database(path: "\(getDocumentsDirectory())/WatchlistDB/blackbird-watchlist.sqlite", options: [.debugPrintEveryQuery, .debugPrintEveryReportedChange, .debugPrintQueryParameterValues])
//        } catch let error {
//            print("[💣] Failed to get Database. \(error)")
//        }
//    }
    
    @StateObject private var vm = HomeViewModel()
//    var database: Blackbird.Database = try! Blackbird.Database.inMemoryDatabase()
//    var database: Blackbird.Database?
//    var database: Blackbird.Database = try! Blackbird.Database(path: "\(NSHomeDirectory())/blackbird-swiftui-test.sqlite", options: [.debugPrintEveryQuery, .debugPrintEveryReportedChange, .debugPrintQueryParameterValues])
//    var database: Blackbird.Database = try! .init(path: "\(NSHomeDirectory())/blackbird-swiftui-test.sqlite")

//    static let fileURL = try! FileManager.default
//        .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        .appendingPathComponent("blackbird-swiftui-test.sqlite")
//    static let fileURL = try! FileManager.default
//        .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        .appendingPathComponent("blackbird-swiftui-test.sqlite")
//    let directory = NSPersistentContainer.defaultDirectoryURL()
//    let url = directory.appendingPathComponent(yourModel + ".sqlite")
    static let fileURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    
    var database: Blackbird.Database = try! Blackbird.Database(path: "\(fileURL)/blackbird-watchlist.sqlite"/*, options: [.debugPrintEveryQuery, .debugPrintEveryReportedChange, .debugPrintQueryParameterValues]*/)
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .toolbar(.hidden)
            }
            .environmentObject(vm)
//            .environment(\.blackbirdDatabase, database)
            .onAppear {
                vm.db = database
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
