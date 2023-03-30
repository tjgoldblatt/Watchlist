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
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddMovieFromExplore() throws {
        app.launch()
        
        app.tabBars["Tab Bar"].buttons["ExploreTab"].tap()
        
        app.textFields["Search for Movies or TV Shows..."].tap()
        
        let aKey = app.keys["A"]
        aKey.tap()
        
        let vKey = app.keys["v"]
        vKey.tap()
        
        let eKey = app.keys["e"]
        eKey.tap()
        
        let nKey = app.keys["n"]
        nKey.tap()
        
        let gKey = app.keys["g"]
        gKey.tap()
        
        app/*@START_MENU_TOKEN@*/.collectionViews/*[[".otherElements[\"ExploreTab\"].collectionViews",".collectionViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .cell).element(boundBy: 0).staticTexts["Add"].tap()
        app/*@START_MENU_TOKEN@*/.buttons["search"]/*[[".keyboards",".buttons[\"search\"]",".buttons[\"Search\"]"],[[[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.tabBars["Tab Bar"].buttons["MovieTab"].tap()
    }
    
    func testMarkAsWatchedAndRate() throws {
        
        let app = XCUIApplication()
        app.tabBars["Tab Bar"]/*@START_MENU_TOKEN@*/.buttons["MovieTab"]/*[[".buttons[\"popcorn.fill\"]",".buttons[\"MovieTab\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.collectionViews.cells.children(matching: .other).element(boundBy: 1).children(matching: .other).element.tap()

        
    }
}
