//
//  BaselineScreenshotTests.swift
//  VitalityUITests
//
//  Walks every Baseline tab and attaches a screenshot of each, so the
//  screens can be reviewed without driving the simulator by hand.
//

import XCTest

final class BaselineScreenshotTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCaptureEveryTab() throws {
        let app = XCUIApplication()
        app.launch()

        capture(app, named: "01-today")

        for (index, tab) in ["Trends", "Plan", "Goals", "You"].enumerated() {
            let button = app.buttons[tab]
            XCTAssertTrue(
                button.waitForExistence(timeout: 5),
                "Tab \(tab) never appeared"
            )
            button.tap()
            capture(app, named: String(format: "%02d-%@", index + 2, tab.lowercased()))
        }

        // The pushed metric detail, reached from a Today tile.
        app.buttons["Today"].tap()
        let tile = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH 'Steps'")
        ).firstMatch
        if tile.waitForExistence(timeout: 5) {
            tile.tap()
            capture(app, named: "06-detail")
        }
    }

    /// Attaches a full-screen screenshot that survives the test run.
    @MainActor
    private func capture(_ app: XCUIApplication, named name: String) {
        // Let the transition settle before the shutter.
        Thread.sleep(forTimeInterval: 1.2)
        let shot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
