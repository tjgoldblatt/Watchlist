//
//  WatchlistApp.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/8/23.
//

// import Blackbird
import Firebase
import SwiftUI

@main
struct WatchlistApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var csManager = ColorSchemeManager()

    @StateObject private var vm = HomeViewModel()
    @StateObject private var authVM = AuthenticationViewModel()

//    // TODO: Remove this
//    var database: Blackbird.Database = try! Blackbird.Database(path:
//    "\(FileManager.default.temporaryDirectory.path)/watchlist-testapp.sqlite")

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(vm)
                .environmentObject(authVM)
//                .environment(\.blackbirdDatabase, database)
                .environmentObject(csManager)
                .onAppear {
                    csManager.applyColorScheme()
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func applicationDidBecomeActive(_: UIApplication) { }

    func applicationWillResignActive(_: UIApplication) { }
}
