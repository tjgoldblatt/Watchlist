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

//    func testAddMovieFromExplore() throws {
//        app.tabBars["Tab Bar"].buttons["ExploreTab"].tap()
//
//        app.textFields["Search for Movies or TV Shows..."].tap()
//
//        let aKey = app.keys["A"]
//        aKey.tap()
//
//        let vKey = app.keys["v"]
//        vKey.tap()
//
//        let eKey = app.keys["e"]
//        eKey.tap()
//
//        let nKey = app.keys["n"]
//        nKey.tap()
//
//        let gKey = app.keys["g"]
//        gKey.tap()
//
//        app/*@START_MENU_TOKEN@*/.collectionViews/*[[".otherElements[\"ExploreTab\"].collectionViews",".collectionViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .cell).element(boundBy: 0).staticTexts["Add"].tap()
//        app/*@START_MENU_TOKEN@*/.buttons["search"]/*[[".keyboards",".buttons[\"search\"]",".buttons[\"Search\"]"],[[[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
//        app.tabBars["Tab Bar"].buttons["MovieTab"].tap()
//    }
    
    func test_mark_as_watched_and_rate() throws {
        
        let app = XCUIApplication()
        app.tabBars["Tab Bar"]/*@START_MENU_TOKEN@*/.buttons["MovieTab"]/*[[".buttons[\"popcorn.fill\"]",".buttons[\"MovieTab\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.collectionViews.cells.children(matching: .other).element(boundBy: 1).children(matching: .other).element.tap()

    }
    
    func test_add_movie_from_explore() throws {
        
    }
}
