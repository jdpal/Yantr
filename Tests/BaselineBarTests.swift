import XCTest
@testable import BaselineBar

final class BaselineBarTests: XCTestCase {
    func testCGRectCodableRoundTrip() throws {
        let source = CGRect(x: 10, y: 20, width: 30, height: 40)
        let encoded = try JSONEncoder().encode(CGRectCodable(source))
        let decoded = try JSONDecoder().decode(CGRectCodable.self, from: encoded)
        XCTAssertEqual(decoded.cgRect, source)
    }

    func testVisibilityRawValuesAreStable() {
        XCTAssertEqual(MenuBarVisibility.visible.rawValue, "Visible")
        XCTAssertEqual(MenuBarVisibility.automatic.rawValue, "Auto")
        XCTAssertEqual(MenuBarVisibility.hidden.rawValue, "Hidden")
    }
}
