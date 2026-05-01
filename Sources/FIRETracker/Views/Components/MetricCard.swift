import SwiftUI

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .monospacedDigit()

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous)
                .stroke(AppDesign.border, lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
        .overlay(alignment: .topTrailing) {
            Image(systemName: systemImage)
                .foregroundStyle(tint.opacity(0.22))
                .font(.title)
                .padding(14)
        }
    }
}
