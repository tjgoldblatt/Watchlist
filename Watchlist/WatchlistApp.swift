//
//  WatchlistApp.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/8/23.
//

import Firebase
import SwiftUI

@main
struct WatchlistApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var csManager = ColorSchemeManager()

    @StateObject private var vm = HomeViewModel()
    @StateObject private var authVM = AuthenticationViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(vm)
                .environmentObject(authVM)
                .environmentObject(csManager)
                .onAppear {
                    csManager.applyColorScheme()
                }
                .onOpenURL { url in
                    vm.deepLinkURL = url
                    vm.selectedTab = .explore
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
