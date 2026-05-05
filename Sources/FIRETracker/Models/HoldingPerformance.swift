import Foundation

struct HoldingPerformance {
    let holding: HoldingLot
    let latestPrice: Decimal?
    var liquidations: [LiquidationLot] = []

    var displayPrice: Decimal {
        latestPrice ?? holding.boughtAt
    }

    var hasLatestPrice: Bool {
        latestPrice != nil
    }

    var remainingShares: Decimal {
        LiquidationCalculator.remainingShares(for: holding, liquidations: liquidations)
    }

    var openCostBasis: Decimal {
        LiquidationCalculator.openCostBasis(for: holding, liquidations: liquidations)
    }

    var realizedGain: Decimal {
        LiquidationCalculator.realizedGain(from: liquidations)
    }

    var currentValue: Decimal {
        guard let latestPrice else {
            return openCostBasis
        }

        return remainingShares * latestPrice
    }

    var unrealizedGain: Decimal {
        guard hasLatestPrice else {
            return 0
        }

        return currentValue - openCostBasis
    }

    var unrealizedGainPercent: Decimal {
        guard openCostBasis > 0 else {
            return 0
        }

        return unrealizedGain / openCostBasis
    }

    var priceGrowth: Decimal {
        guard let latestPrice else {
            return 0
        }

        return latestPrice - holding.boughtAt
    }

    var priceGrowthPercent: Decimal {
        guard holding.boughtAt > 0 else {
            return 0
        }

        return priceGrowth / holding.boughtAt
    }
}
