import Foundation

struct PortfolioMetric {
    let invested: Decimal
    let currentValue: Decimal
    let gain: Decimal
    let gainPercent: Decimal
    let realizedGain: Decimal
    let annualizedReturn: Decimal?
    let missingPriceCount: Int

    var totalGain: Decimal {
        gain + realizedGain
    }

    var isPositive: Bool {
        totalGain >= 0
    }

    var hasMissingPrices: Bool {
        missingPriceCount > 0
    }
}
