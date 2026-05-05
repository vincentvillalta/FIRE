import Foundation

enum PortfolioCalculator {
    static func metrics(holdings: [HoldingLot], prices: [PriceSnapshot], liquidations: [LiquidationLot] = []) -> PortfolioMetric {
        let priceMap = Dictionary(uniqueKeysWithValues: prices.map { ($0.ticker, $0.price) })
        let liquidationsByHoldingID = Dictionary(grouping: liquidations, by: \.holdingID)
        let invested = holdings.reduce(Decimal.zero) { partial, lot in
            partial + LiquidationCalculator.openCostBasis(for: lot, liquidations: liquidationsByHoldingID[lot.id] ?? [])
        }
        let currentValue = holdings.reduce(Decimal.zero) { partial, lot in
            let performance = HoldingPerformance(holding: lot, latestPrice: priceMap[lot.ticker], liquidations: liquidationsByHoldingID[lot.id] ?? [])
            return partial + performance.currentValue
        }
        let missingPriceCount = holdings.filter { lot in
            LiquidationCalculator.remainingShares(for: lot, liquidations: liquidationsByHoldingID[lot.id] ?? []) > 0 && priceMap[lot.ticker] == nil
        }.count
        let gain = currentValue - invested
        let gainPercent = invested == 0 ? 0 : gain / invested
        let realizedGain = LiquidationCalculator.realizedGain(from: liquidations)
        let annualizedReturn = annualizedReturn(holdings: holdings, currentValue: currentValue, invested: invested)
        return PortfolioMetric(
            invested: invested,
            currentValue: currentValue,
            gain: gain,
            gainPercent: gainPercent,
            realizedGain: realizedGain,
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
