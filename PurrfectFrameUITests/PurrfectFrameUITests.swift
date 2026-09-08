import XCTest

final class PurrfectFrameUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchHomeAndPlay() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Purrfect Frame"].waitForExistence(timeout: 5))
        saveShot("home")
        XCTAssertTrue(app.buttons["play-button"].exists)
        app.buttons["play-button"].tap()
        XCTAssertTrue(app.buttons["shutter-button"].waitForExistence(timeout: 5))
        saveShot("play")
        app.buttons["shutter-button"].tap()
        XCTAssertTrue(app.staticTexts["result-title"].waitForExistence(timeout: 6))
        saveShot("result")
    }

    func testWorldsAndSettings() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 5))
        app.buttons["Worlds"].tap()
        XCTAssertTrue(app.staticTexts["Cat Café"].waitForExistence(timeout: 5))
        saveShot("worlds")
        app.buttons["back-button"].tap()
        XCTAssertTrue(app.buttons["play-button"].waitForExistence(timeout: 5))
        app.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 5))
        saveShot("settings")
    }

    private func saveShot(_ name: String) {
        let shot = XCUIScreen.main.screenshot()
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("pf-\(name).png")
        try? shot.pngRepresentation.write(to: url)
        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
