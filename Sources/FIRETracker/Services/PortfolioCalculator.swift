import Foundation

enum PortfolioCalculator {
    static func metrics(holdings: [HoldingLot], prices: [PriceSnapshot]) -> PortfolioMetric {
        let priceMap = Dictionary(uniqueKeysWithValues: prices.map { ($0.ticker, $0.price) })
        let invested = holdings.reduce(Decimal.zero) { $0 + $1.invested }
        let currentValue = holdings.reduce(Decimal.zero) { partial, lot in
            let performance = HoldingPerformance(holding: lot, latestPrice: priceMap[lot.ticker])
            return partial + performance.currentValue
        }
        let missingPriceCount = holdings.filter { priceMap[$0.ticker] == nil }.count
        let gain = currentValue - invested
        let gainPercent = invested == 0 ? 0 : gain / invested
        let annualizedReturn = annualizedReturn(holdings: holdings, currentValue: currentValue, invested: invested)
        return PortfolioMetric(
            invested: invested,
            currentValue: currentValue,
            gain: gain,
            gainPercent: gainPercent,
            annualizedReturn: annualizedReturn,
            missingPriceCount: missingPriceCount
        )
    }

    static func costPerShare(holding: HoldingLot) -> Decimal {
        holding.shareCount == 0 ? 0 : holding.invested / holding.shareCount
    }

    static func projections(from value: Decimal, annualGrowth: Decimal = 0.07, years: Int = 30) -> [ProjectionPoint] {
        (0...years).map { year in
            let projected = value.doubleValue * pow(1 + annualGrowth.doubleValue, Double(year))
            return ProjectionPoint(year: year, value: Decimal(projected))
        }
    }

    private static func annualizedReturn(holdings: [HoldingLot], currentValue: Decimal, invested: Decimal) -> Decimal? {
        guard invested > 0, currentValue > 0, let oldest = holdings.map(\.purchaseDate).min() else { return nil }
        let years = max(Date.now.timeIntervalSince(oldest) / 31_557_600, 0.01)
        let value = pow(currentValue.doubleValue / invested.doubleValue, 1 / years) - 1
        return Decimal(value)
    }
}
