//
//  FocusTimerUITests.swift
//  VitalityUITests
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import XCTest

/// Drives the focus timer through the real UI to confirm it starts and stops.
final class FocusTimerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testStartingAndStoppingFocusTimer() throws {
        let app = XCUIApplication()
        app.launch()

        let start = app.buttons["Start focus timer for Drink water"]
        XCTAssertTrue(start.waitForExistence(timeout: 10), "Focus button should be on the card")

        start.tap()

        // Starting swaps the control to Stop, which only appears while a session runs.
        let stop = app.buttons["Stop focus timer for Drink water"]
        XCTAssertTrue(stop.waitForExistence(timeout: 5), "Timer should start and show Stop")

        stop.tap()

        XCTAssertTrue(start.waitForExistence(timeout: 5), "Stopping should restore the Focus button")
    }
}
