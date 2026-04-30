import Foundation

struct PortfolioMetric {
    let invested: Decimal
    let currentValue: Decimal
    let gain: Decimal
    let gainPercent: Decimal
    let annualizedReturn: Decimal?
    let missingPriceCount: Int

    var isPositive: Bool {
        gain >= 0
    }

    var hasMissingPrices: Bool {
        missingPriceCount > 0
    }
}
