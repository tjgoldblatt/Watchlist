//
//  WatchlistUserAuthTests.swift
//  WatchlistUITests
//
//  Created by TJ Goldblatt on 4/20/23.
//

import XCTest

final class WatchlistUserAuthTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func test_sign_in_user_with_google() throws {
        app.staticTexts["Continue with Google"].tap()
        
        addUIInterruptionMonitor(withDescription: "System Dialog") {
            (alert) -> Bool in
            alert.buttons["Continue"].tap()
            return true
        }
        app.tap()
        
        app.staticTexts["Movies"].tap()
    }
    
    func test_sign_out_user() throws {
        app.tabBars["Tab Bar"].buttons["person.fill"].tap()
        app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].images["Settings"].tap()
        app.collectionViews.buttons["Log Out"].tap()
        app.images["popcorn.fill"].tap()
    }
}
