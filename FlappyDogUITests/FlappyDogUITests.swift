import XCTest

final class FlappyDogUITests: XCTestCase {
    /// Play → score → crash → Play again. `-uitest` seeds the game and uses wide, slow-falling gaps.
    @MainActor
    func testPlayScoreCrashPlayAgain() {
        let app = XCUIApplication()
        app.launchArguments = ["-uitest"]
        app.launch()

        app.buttons["Play"].tap()
        XCTAssertTrue(app.staticTexts["Tap to fly"].waitForExistence(timeout: 5))
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()

        XCTAssertTrue(app.staticTexts["Game Over"].waitForExistence(timeout: 20))
        let finalScore = Int(app.staticTexts["finalScore"].label) ?? 0
        XCTAssertGreaterThanOrEqual(finalScore, 1)

        let again = app.buttons["Play again"]
        XCTAssertTrue(again.waitForExistence(timeout: 2))
        expectation(for: NSPredicate(format: "isEnabled == true"), evaluatedWith: again)
        waitForExpectations(timeout: 2)
        again.tap()
        XCTAssertTrue(app.staticTexts["Tap to fly"].waitForExistence(timeout: 5))
    }
}
