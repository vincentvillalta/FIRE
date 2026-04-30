import SwiftUI

struct WatchTodayView: View {
    let snapshot: WatchTodaySnapshot
    let updatedAt: Date

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Today")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 4) {
                    Text(snapshot.gain.watchCurrency)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(snapshot.gain >= 0 ? .green : .orange)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    Text("Unrealized \(snapshot.gainPercent.watchPercent)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                WatchMetricRow(title: "Value", value: snapshot.currentValue.watchCurrency)
                WatchMetricRow(title: "Invested", value: snapshot.invested.watchCurrency)

                if let annualizedReturn = snapshot.annualizedReturn {
                    WatchMetricRow(title: "Annualized", value: annualizedReturn.watchPercent)
                }

                if snapshot.missingPriceCount > 0 {
                    Label("\(snapshot.missingPriceCount) price\(snapshot.missingPriceCount == 1 ? "" : "s") missing", systemImage: "exclamationmark.triangle")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }

                WatchUpdatedText(date: updatedAt)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 2)
        }
    }
}

