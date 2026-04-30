import SwiftUI

struct WatchFIREView: View {
    let snapshot: WatchFIRESnapshot
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
                .tint(snapshot.isOnTrack ? .green : .teal)

                WatchMetricRow(title: "Number", value: snapshot.fireNumber.watchCurrency)
                WatchMetricRow(title: "Monthly", value: snapshot.monthlyInvestment.watchCurrency)
                WatchMetricRow(title: "Target", value: snapshot.targetMonthlyInvestment.watchCurrency)

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
    }
}

