//
//  CrashlyticsManager.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 4/20/23.
//

import Foundation
import Combine
import FirebaseCrashlytics

class CrashlyticsManager {
    static func handleCompletition(completition: Subscribers.Completion<Error>) {
        switch completition {
            case .finished:
                break
            case .failure(let error):
                Crashlytics.crashlytics().record(error: error)
        }
    }
    
    static func handleError(error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
    
    static func handleWarning(warning: String) {
        Crashlytics.crashlytics().log("[⚠️] " + warning)
    }
}
