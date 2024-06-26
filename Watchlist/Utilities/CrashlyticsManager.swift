//
//  CrashlyticsManager.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/20/23.
//

import Combine
import FirebaseCrashlytics
import Foundation

class CrashlyticsManager {
    private init() { }

    static func setUserId(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }

    static func handleError(error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }

    static func handleWarning(warning: String) {
        Crashlytics.crashlytics().log("[⚠️] " + warning)
    }
}
