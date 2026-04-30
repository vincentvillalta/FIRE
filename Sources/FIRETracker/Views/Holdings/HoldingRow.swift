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
                    .font(.headline)
                Text(holding.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(performance.currentValue, format: .portfolioCurrency)
                    .font(.subheadline.weight(.semibold))
                Text(performance.hasLatestPrice ? performance.unrealizedGain.formatted(.portfolioCurrency) : "Refresh price")
                    .font(.caption)
                    .foregroundStyle(performance.unrealizedGain >= 0 ? .green : .orange)
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}
