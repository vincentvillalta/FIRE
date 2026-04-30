import XCTest
@testable import FIRETracker

final class PortfolioCalculatorTests: XCTestCase {
    func testTracksMissingPricesSeparatelyFromGain() {
        let holding = HoldingLot(
            ticker: "VWCE",
            name: "FTSE All-World USD (Acc)",
            invested: 2_800,
            boughtAt: Decimal(string: "131.21")!,
            shareCount: Decimal(string: "21.347971")!,
            purchaseDate: Date(timeIntervalSince1970: 0)
        )

        let metric = PortfolioCalculator.metrics(holdings: [holding], prices: [])

        XCTAssertEqual(metric.currentValue, 2_800)
        XCTAssertEqual(metric.gain, 0)
        XCTAssertEqual(metric.missingPriceCount, 1)
        XCTAssertTrue(metric.hasMissingPrices)
    }
}
