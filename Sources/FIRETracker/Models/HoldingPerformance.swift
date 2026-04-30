import Foundation

struct HoldingPerformance {
    let holding: HoldingLot
    let latestPrice: Decimal?

    var displayPrice: Decimal {
        latestPrice ?? holding.boughtAt
    }

    var hasLatestPrice: Bool {
        latestPrice != nil
    }

    var currentValue: Decimal {
        guard let latestPrice else {
            return holding.invested
        }

        return holding.shareCount * latestPrice
    }

    var unrealizedGain: Decimal {
        guard hasLatestPrice else {
            return 0
        }

        return currentValue - holding.invested
    }

    var unrealizedGainPercent: Decimal {
        guard holding.invested > 0 else {
            return 0
        }

        return unrealizedGain / holding.invested
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
