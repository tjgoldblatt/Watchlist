//
//  TaskDataStore.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/14/23.
//

import Foundation
import SQLite

class WatchlistDataStore {
    
    static let DIR_TASK_DB = "WatchlistDB"
    static let STORE_NAME = "watchlist-test.sqlite3"
    
    private let watchlist = Table("watchlist")
    
    private let id = Expression<Int64>("id")
    private let watched = Expression<Bool>("watched")
    private let mediaType = Expression<String>("mediaType")
    private let media = Expression<Data>("media")
    
    static let shared = WatchlistDataStore()
    
    let dbPath: String?
    
    private var db: Connection? = nil
    
    private init() {
        if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dirPath = docDir.appendingPathComponent(Self.DIR_TASK_DB)
            do {
                try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
                let dbPath = dirPath.appendingPathComponent(Self.STORE_NAME).path
                db = try Connection(dbPath)
                self.dbPath = dbPath
                
                createTable()
                print("SQLiteDataStore init successfully at: \(dbPath) ")
            } catch {
                db = nil
                dbPath = nil
                print("SQLiteDataStore init error: \(error)")
            }
        } else {
            dbPath = nil
            db = nil
        }
    }
    
    private func createTable() {
        guard let database = db else {
            return
        }
        do {
            try database.run(watchlist.create { table in
                table.column(id, primaryKey: .autoincrement)
                table.column(watched)
                table.column(mediaType)
                table.column(media)
            })
            print("Table Created...")
        } catch {
            print(error)
        }
    }
    
    func insert(id: Int64) -> Int64? {
        guard let database = db else { return nil }
        
        let insert = watchlist.insert(
            self.id <- id,
            self.watched <- true,
            self.mediaType <- "tv",
            self.media <- Data()
        )
        do {
            let rowID = try database.run(insert)
            return rowID
        } catch {
            print(error)
            return nil
        }
    }
    
    func getAllTasks() {
//        var tasks: [Media] = []
        guard let database = db else { return }
        var count = 1
        do {
            for media in try database.prepare(self.watchlist) {
//                print(media)
                print("Count is \(count)")
                count += 1
//                tasks.append(Task(id: task[id], name: task[taskName], date: task[date], status: task[status]))
            }
        } catch {
            print(error)
        }
        return
    }
}
