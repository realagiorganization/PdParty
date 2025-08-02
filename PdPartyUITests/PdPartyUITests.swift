import XCTest

class PdPartyUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testOpenTriSampSample() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        let tables = app.tables
        tables.staticTexts["samples"].tap()
        tables.staticTexts["pdparty"].tap()
        tables.staticTexts["TriSamp"].tap()
        snapshot("TriSamp")
        XCTAssertTrue(app.navigationBars["TriSamp"].exists)
    }
}
