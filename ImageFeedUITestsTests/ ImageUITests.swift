//
//  ImageFeedUITestsTests.swift
//  ImageFeedUITestsTests
//
//  Created by William White on 24.10.2025.
//


import XCTest

class Image_FeedUITests: XCTestCase {
    var app: XCUIApplication! // Для второго теста
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication() // Для второго теста
        app.launchArguments = ["-uiTesting"] // Для второго теста
       
       
        
        app.launch()
        
    }
    
    
    func testAuth() throws {
        print(app.debugDescription)
        
        app.buttons["Authenticate"].tap()
        
        print(app.debugDescription)
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 15))
        
        print(app.debugDescription)

        let loginTextField = webView.descendants(matching: .textField).element
        
        print(app.debugDescription)
        
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        print(app.debugDescription)
        
        loginTextField.tap()
        loginTextField.typeText("")
        
        print(app.debugDescription)
       
        let doneButton = app.keyboards.buttons["Done"]
        if doneButton.exists {
            doneButton.tap()
        } else {
            app.keyboards.buttons["Return"].tap()
        }
        
        print(app.debugDescription)
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        
        print(app.debugDescription)
        
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("")
        
        print(app.debugDescription)
       
        let keyboards = app.keyboards
        if keyboards.buttons["Done"].exists {
            keyboards.buttons["Done"].tap()
        } else if keyboards.buttons["Return"].exists {
            keyboards.buttons["Return"].tap()
        } else if keyboards.keys["done"].exists {
            keyboards.keys["done"].tap()
        }
        
        print(app.debugDescription)
        
        webView.buttons["Login"].tap()
        
        print(app.debugDescription)
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        
        print(app.debugDescription)
    }
    
    
    
//    func testAuth() throws {
//        app.buttons["Authenticate"].tap()
//        
//        let webView = app.webViews["UnsplashWebView"]
//        
//        XCTAssertTrue(webView.waitForExistence(timeout: 5))
//
//        let loginTextField = webView.descendants(matching: .textField).element
//        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
//        
//        loginTextField.tap()
//        loginTextField.typeText("<>")
//        webView.swipeUp()
//        
//        let passwordTextField = webView.descendants(matching: .secureTextField).element
//        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
//        
//        passwordTextField.tap()
//        passwordTextField.typeText("<>")
//        webView.swipeUp()
//        
//        webView.buttons["Login"].tap()
//        
//        let tablesQuery = app.tables
//        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
//        
//        XCTAssertTrue(cell.waitForExistence(timeout: 5))
//    }
    
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let isUITesting = ProcessInfo.processInfo.arguments.contains("-uiTesting")
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["like button off"].tap()
        cellToLike.buttons["like button on"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        print(app.debugDescription)
        
        let navBackButton = app.buttons["backward button white"]
        XCTAssertTrue(navBackButton.waitForExistence(timeout: 5))
        navBackButton.tap()
    }
    
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        XCTAssertTrue(app.staticTexts["profile_name_label"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["profile_login_label"].waitForExistence(timeout: 5))
        
        app.buttons["logout button"].tap()
        
        app.alerts["Выйти из аккаунта?"].scrollViews.otherElements.buttons["Выйти"].tap()
    }
}
