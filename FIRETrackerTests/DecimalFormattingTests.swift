import XCTest
@testable import FIRETracker

final class DecimalFormattingTests: XCTestCase {
    func testParsesCommaDecimalValues() {
        XCTAssertEqual(Decimal.clean("123,45"), Decimal(string: "123.45"))
    }

    func testParsesCurrencyValues() {
        XCTAssertEqual(Decimal.clean("€1,234.56"), Decimal(string: "1234.56"))
    }
}
