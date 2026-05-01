import SwiftUI

enum AppDesign {
    static let background = dynamic(light: 0xF5F5F2, dark: 0x0E0E10)
    static let groupedBackground = dynamic(light: 0xEFEFEC, dark: 0x0A0A0C)
    static let surface = dynamic(light: 0xFFFFFF, dark: 0x18181B)
    static let surfaceMuted = dynamic(light: 0xFAFAF8, dark: 0x1C1C20)
    static let accent = dynamic(light: 0x0E8C7E, dark: 0x3FBFAE)
    static let accentSoft = accent.opacity(0.10)
    static let accentText = dynamic(light: 0x0A6B60, dark: 0x5FD4C3)
    static let positive = accent
    static let negative = dynamic(light: 0xB33A3A, dark: 0xD87070)
    static let border = Color(.separator).opacity(0.28)
    static let cardRadius: CGFloat = 8

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}

struct DesignCard<Content: View>: View {
    var padding: CGFloat = 16
    var background: Color = AppDesign.surface
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .background(background, in: RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous)
                    .stroke(AppDesign.border, lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }
}

struct SectionLabel: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
            .tracking(0.4)
            .padding(.horizontal, 4)
    }
}

struct ValueRow: View {
    let title: String
    let value: String
    var valueColor: Color = .secondary

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.primary)

            Spacer(minLength: 12)

            Text(value)
                .foregroundStyle(valueColor)
                .fontWeight(.medium)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

struct ProgressLine: View {
    let value: Double
    var tint: Color = AppDesign.accent

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.separator).opacity(0.16))

                Capsule()
                    .fill(tint)
                    .frame(width: proxy.size.width * min(max(value, 0), 1))
            }
        }
        .frame(height: 6)
    }
}
