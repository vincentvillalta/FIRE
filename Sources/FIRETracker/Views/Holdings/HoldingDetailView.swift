import SwiftUI

struct HoldingDetailView: View {
    let holding: HoldingLot
    let latestPrice: Decimal?

    private var costPerShare: Decimal {
        PortfolioCalculator.costPerShare(holding: holding)
    }

    private var performance: HoldingPerformance {
        HoldingPerformance(holding: holding, latestPrice: latestPrice)
    }

    var body: some View {
        List {
            Section {
                LabeledContent("Shares", value: holding.shareCount.formatted())
                LabeledContent("Invested", value: holding.invested.formatted(.portfolioCurrency))
                LabeledContent("Bought at", value: holding.boughtAt.formatted(.portfolioCurrency))
                LabeledContent("Cost per share", value: costPerShare.formatted(.portfolioCurrency))
                LabeledContent("Latest price", value: performance.hasLatestPrice ? performance.displayPrice.formatted(.portfolioCurrency) : "Refresh needed")
            }

            Section("Performance") {
                LabeledContent("Current value", value: performance.currentValue.formatted(.portfolioCurrency))
                LabeledContent("Investment gain", value: performance.hasLatestPrice ? performance.unrealizedGain.formatted(.portfolioCurrency) : "Refresh needed")
                LabeledContent("Investment return", value: performance.hasLatestPrice ? performance.unrealizedGainPercent.formatted(.portfolioPercent) : "Refresh needed")
                LabeledContent("Price growth/share", value: performance.hasLatestPrice ? performance.priceGrowth.formatted(.portfolioCurrency) : "Refresh needed")
                LabeledContent("Price growth", value: performance.hasLatestPrice ? performance.priceGrowthPercent.formatted(.portfolioPercent) : "Refresh needed")
            }
        }
        .navigationTitle(holding.ticker)
        .navigationBarTitleDisplayMode(.large)
    }
}
