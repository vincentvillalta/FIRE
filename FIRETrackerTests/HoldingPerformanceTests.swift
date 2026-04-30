import XCTest
@testable import FIRETracker

final class HoldingPerformanceTests: XCTestCase {
    func testComputesInvestmentGrowthAgainstLatestPrice() {
        let holding = HoldingLot(
            ticker: "VWCE",
            name: "FTSE All-World USD (Acc)",
            invested: Decimal(string: "2800")!,
            boughtAt: Decimal(string: "131.21")!,
            shareCount: Decimal(string: "21.347971")!,
            purchaseDate: Date(timeIntervalSince1970: 0)
        )

        let performance = HoldingPerformance(
            holding: holding,
            latestPrice: Decimal(string: "151")!
        )

        XCTAssertEqual(performance.currentValue.rounded(scale: 2), Decimal(string: "3224.54"))
        XCTAssertEqual(performance.unrealizedGain.rounded(scale: 2), Decimal(string: "424.54"))
        XCTAssertEqual(performance.priceGrowth, Decimal(string: "19.79"))
    }

    func testMissingPriceDoesNotCreateFakeGainFromRounding() {
        let holding = HoldingLot(
            ticker: "VWCE",
            name: "FTSE All-World USD (Acc)",
            invested: Decimal(string: "2800")!,
            boughtAt: Decimal(string: "131.21")!,
            shareCount: Decimal(string: "21.347971")!,
            purchaseDate: Date(timeIntervalSince1970: 0)
        )

        let performance = HoldingPerformance(holding: holding, latestPrice: nil)

        XCTAssertEqual(performance.currentValue, Decimal(string: "2800"))
        XCTAssertEqual(performance.unrealizedGain, 0)
    }
}
