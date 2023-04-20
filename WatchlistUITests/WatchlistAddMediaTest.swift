//
//  WatchlistAddMediaTest.swift
//  WatchlistUITests
//
//  Created by TJ Goldblatt on 3/29/23.
//

import XCTest

final class WatchlistAddMediaTest: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        app.launch()
        continueAfterFailure = false
    }
    
    func test_add_movie_from_explore() throws {
        let tabBar = app.tabBars["Tab Bar"]
        tabBar.buttons["ExploreTab"].tap()
        app.textFields["Search for Movies or TV Shows..."].tap()
        
        let tKey = app.keys["T"]
        tKey.tap()
        
        let hKey = app.keys["h"]
        hKey.tap()
        
        let eKey = app.keys["e"]
        eKey.tap()
        
        app.buttons["search"].tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 0).staticTexts["Add"].tap()
        
        tabBar.buttons["MovieTab"].tap()
        
        app.collectionViews.cells.children(matching: .other).element(boundBy: 1).children(matching: .other).element.tap()
    }
    
    func test_delete_movie_with_modal() throws {
        app.collectionViews.cells.children(matching: .other).element(boundBy: 1).children(matching: .other).element.tap()
        app.scrollViews.otherElements.buttons["Added"].tap()
        app.alerts["Are you sure you'd like to delete from your Watchlist?"].scrollViews.otherElements.buttons["Delete"].tap()
    }
}
