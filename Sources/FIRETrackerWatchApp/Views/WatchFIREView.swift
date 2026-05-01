import SwiftUI

struct WatchFIREView: View {
    let snapshot: WatchFIRESnapshot
    let currencyCode: String
    let updatedAt: Date

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("FIRE")
                    .font(.headline)

                Gauge(value: min(max(snapshot.progress, 0), 1)) {
                    Text("Progress")
                } currentValueLabel: {
                    Text(snapshot.progress.watchPercent)
                }
                .gaugeStyle(.accessoryCircularCapacity)
                .tint(snapshot.isOnTrack ? WatchDesign.positive : WatchDesign.accent)

                WatchMetricRow(title: "Number", value: snapshot.fireNumber.watchCurrency(code: currencyCode))
                WatchMetricRow(title: "Monthly", value: snapshot.monthlyInvestment.watchCurrency(code: currencyCode))
                WatchMetricRow(title: "Target", value: snapshot.targetMonthlyInvestment.watchCurrency(code: currencyCode))

                if let fireAge = snapshot.fireAge {
                    WatchMetricRow(title: "FIRE age", value: "\(fireAge)")
                }

                if let fireDate = snapshot.fireDate {
                    Text(fireDate, format: .dateTime.month().year())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Set the plan on iPhone")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                WatchUpdatedText(date: updatedAt)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 2)
        }
        .background(WatchDesign.background)
    }
}
