import SwiftUI

struct HoldingRow: View {
    let holding: HoldingLot
    let latestPrice: Decimal?

    private var performance: HoldingPerformance {
        HoldingPerformance(holding: holding, latestPrice: latestPrice)
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(holding.ticker)
                    .font(.subheadline.weight(.semibold))
                Text(holding.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text("\(holding.shareCount.formatted()) sh · avg \(PortfolioCalculator.costPerShare(holding: holding).formatted(.portfolioCurrency))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                if let isin = holding.isin {
                    Text(isin)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(performance.currentValue, format: .portfolioCurrency)
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()
                Text(performance.hasLatestPrice ? performance.unrealizedGain.formatted(.portfolioCurrency) : "Refresh price")
                    .font(.caption)
                    .foregroundStyle(performance.unrealizedGain >= 0 ? AppDesign.positive : AppDesign.negative)
                    .monospacedDigit()
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
    }
}
