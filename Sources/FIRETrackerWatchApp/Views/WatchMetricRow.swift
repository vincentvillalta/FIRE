import SwiftUI

struct WatchMetricRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 6)

            Text(value)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .accessibilityElement(children: .combine)
        .padding(.vertical, 3)
        .padding(.horizontal, 8)
        .background(WatchDesign.surface, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
