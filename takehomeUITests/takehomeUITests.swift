import XCTest

/// Smoke coverage for the onboarding entry point. The flow itself (camera,
/// voice, success) is covered by ViewModel-level Swift Testing suites in
/// `takehomeTests/`; this file's job is to confirm the app boots into the
/// sign-in screen with the expected affordances visible.
final class takehomeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func test_app_launches_to_sign_in_screen() {
        let app = XCUIApplication()
        app.launch()

        let hero = app.staticTexts["YOUR AI SELF IS\nWAITING"]
        XCTAssertTrue(
            hero.waitForExistence(timeout: 5),
            "Expected sign-in hero copy to be visible on launch."
        )
        XCTAssertTrue(
            app.buttons["Continue"].exists,
            "Expected Continue button on the sign-in screen."
        )
    }
}
