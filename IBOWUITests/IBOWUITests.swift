import XCTest

/// End-to-end smoke tests. The app is launched with `-ui-testing`, which swaps the network for fixed data.
@MainActor
final class IBOWUITests: XCTestCase {
    override func setUp() async throws {
        continueAfterFailure = false
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        return app
    }

    func testSearchScreenAppears() {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["Aeropuertos"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["Códigos ICAO de aeropuertos"].exists)
    }

    func testSearchingAnAirportAndSelectingItOpensTheDetail() {
        let app = launchApp()

        let field = app.textFields["Códigos ICAO de aeropuertos"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText("LEMD")

        let row = app.descendants(matching: .any).matching(identifier: "metar-row-LEMD").firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 5), "The result row should appear after the debounce")
        row.tap()

        let detail = app.descendants(matching: .any).matching(identifier: "detail-screen").firstMatch
        XCTAssertTrue(detail.waitForExistence(timeout: 5), "Selecting a result should show its detail")
    }
}
