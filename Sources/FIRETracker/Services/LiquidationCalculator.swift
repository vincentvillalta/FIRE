import Foundation

enum LiquidationCalculator {
    static func liquidations(for holding: HoldingLot, in liquidations: [LiquidationLot]) -> [LiquidationLot] {
        liquidations
            .filter { $0.holdingID == holding.id }
            .sorted { $0.saleDate < $1.saleDate }
    }

    static func soldShares(for holding: HoldingLot, liquidations: [LiquidationLot]) -> Decimal {
        liquidations.reduce(.zero) { $0 + $1.soldShares }
    }

    static func remainingShares(for holding: HoldingLot, liquidations: [LiquidationLot]) -> Decimal {
        max(holding.shareCount - soldShares(for: holding, liquidations: liquidations), 0)
    }

    static func costBasis(for holding: HoldingLot, shares: Decimal) -> Decimal {
        guard holding.shareCount > 0 else { return 0 }
        return holding.invested * min(max(shares, 0), holding.shareCount) / holding.shareCount
    }

    static func openCostBasis(for holding: HoldingLot, liquidations: [LiquidationLot]) -> Decimal {
        costBasis(for: holding, shares: remainingShares(for: holding, liquidations: liquidations))
    }

    static func realizedGain(from liquidations: [LiquidationLot]) -> Decimal {
        liquidations.reduce(.zero) { $0 + ($1.proceeds - $1.costBasis) }
    }
}
