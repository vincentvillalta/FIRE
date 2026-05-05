import SwiftData
import SwiftUI

struct HoldingDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allLiquidations: [LiquidationLot]

    let holding: HoldingLot
    let latestPrice: Decimal?

    @State private var isEditing = false
    @State private var isLiquidating = false

    private var liquidations: [LiquidationLot] {
        LiquidationCalculator.liquidations(for: holding, in: allLiquidations)
    }

    private var costPerShare: Decimal {
        PortfolioCalculator.costPerShare(holding: holding)
    }

    private var performance: HoldingPerformance {
        HoldingPerformance(holding: holding, latestPrice: latestPrice, liquidations: liquidations)
    }

    var body: some View {
        List {
            Section {
                LabeledContent("ISIN", value: holding.isin ?? "Not set")
                LabeledContent("Open shares", value: performance.remainingShares.formatted())
                LabeledContent("Original shares", value: holding.shareCount.formatted())
                LabeledContent("Open cost basis", value: performance.openCostBasis.formatted(.portfolioCurrency))
                LabeledContent("Original invested", value: holding.invested.formatted(.portfolioCurrency))
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

            Section("Liquidations") {
                LabeledContent("Realized gain/loss", value: performance.realizedGain.formatted(.portfolioCurrency))

                ForEach(liquidations) { liquidation in
                    VStack(alignment: .leading, spacing: 6) {
                        LabeledContent(liquidation.saleDate.formatted(date: .abbreviated, time: .omitted), value: (liquidation.proceeds - liquidation.costBasis).formatted(.portfolioCurrency))
                        Text("\(liquidation.soldShares.formatted()) shares at \(liquidation.soldAt.formatted(.portfolioCurrency))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            modelContext.delete(liquidation)
                            try? modelContext.save()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle(holding.ticker)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Liquidate") {
                    isLiquidating = true
                }
                .disabled(performance.remainingShares <= 0)

                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditEntryView(holding: holding)
        }
        .sheet(isPresented: $isLiquidating) {
            LiquidateEntryView(holding: holding, latestPrice: latestPrice, liquidations: liquidations)
        }
    }
}
