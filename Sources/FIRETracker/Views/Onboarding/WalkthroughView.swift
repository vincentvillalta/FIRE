import SwiftUI

struct WalkthroughView: View {
    let onComplete: (MainTab) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selection = 0

    private let steps = WalkthroughStep.steps

    var body: some View {
        ZStack {
            WalkthroughBackground()

            VStack(spacing: 0) {
                TabView(selection: $selection) {
                    ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                        WalkthroughPage(step: step)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                WalkthroughPagination(total: steps.count, current: selection)
                    .padding(.bottom, 18)

                VStack(spacing: 12) {
                    Button(primaryTitle) {
                        advance()
                    }
                    .buttonStyle(WalkthroughPrimaryButtonStyle())

                    if selection == steps.indices.last {
                        Button("I'll explore first") {
                            onComplete(.today)
                        }
                        .buttonStyle(WalkthroughSecondaryButtonStyle())
                    } else {
                        Button("Skip") {
                            onComplete(.today)
                        }
                        .buttonStyle(WalkthroughSecondaryButtonStyle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
        }
        .ignoresSafeArea()
    }

    private var primaryTitle: String {
        if selection == 0 {
            "Begin"
        } else if selection == steps.indices.last {
            "Add my first position"
        } else {
            "Continue"
        }
    }

    private func advance() {
        guard selection < steps.count - 1 else {
            onComplete(.add)
            return
        }

        withAnimation(reduceMotion ? nil : .snappy(duration: 0.28)) {
            selection += 1
        }
    }
}

private struct WalkthroughStep: Identifiable {
    enum Illustration {
        case bloom
        case quote
        case formula
        case flames
        case levers
        case appOverview
        case privacy
        case ready
    }

    let id = UUID()
    let eyebrow: String?
    let title: String
    let body: String
    let illustration: Illustration

    static let steps: [WalkthroughStep] = [
        WalkthroughStep(
            eyebrow: nil,
            title: "Quietly, toward freedom",
            body: "A calm tracker for your journey to financial independence. No accounts, no noise.",
            illustration: .bloom
        ),
        WalkthroughStep(
            eyebrow: "The idea",
            title: "FIRE - Financial Independence, Retire Early",
            body: "Save and invest enough that the income from your portfolio covers your annual spending. Work becomes optional.",
            illustration: .quote
        ),
        WalkthroughStep(
            eyebrow: "The math",
            title: "The 4% rule",
            body: "If you withdraw 4% per year, history says your portfolio likely lasts 30+ years. So your goal is 25x your annual spend.",
            illustration: .formula
        ),
        WalkthroughStep(
            eyebrow: "Flavors",
            title: "Lean, FIRE, Fat",
            body: "Same idea, three lifestyles. Pick what fits - your number scales with your spending.",
            illustration: .flames
        ),
        WalkthroughStep(
            eyebrow: "Two levers",
            title: "What moves the needle",
            body: "Only two things shorten the path. The app shows both, every day.",
            illustration: .levers
        ),
        WalkthroughStep(
            eyebrow: "This app",
            title: "Track. Project. Stay calm.",
            body: "Log your investments, set your spend, and see how many years until freedom - recalculated quietly each day.",
            illustration: .appOverview
        ),
        WalkthroughStep(
            eyebrow: "Privacy",
            title: "Local-first, by design",
            body: "Your numbers are yours. Nothing leaves the device unless you choose.",
            illustration: .privacy
        ),
        WalkthroughStep(
            eyebrow: "You're set",
            title: "Add your first position",
            body: "A few minutes today. Years of clarity ahead.",
            illustration: .ready
        )
    ]
}

private struct WalkthroughBackground: View {
    var body: some View {
        ZStack {
            AppDesign.background

            RadialGradient(
                colors: [AppDesign.accent.opacity(0.22), .clear],
                center: .top,
                startRadius: 24,
                endRadius: 360
            )

            LinearGradient(
                colors: [.clear, AppDesign.groupedBackground.opacity(0.72)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

private struct WalkthroughPage: View {
    let step: WalkthroughStep

    var body: some View {
        VStack(spacing: 30) {
            Spacer(minLength: 24)

            illustration
                .frame(height: 230)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            WalkthroughCopy(step: step)
                .padding(.horizontal, 28)

            Spacer(minLength: 18)
        }
        .padding(.top, 64)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var illustration: some View {
        switch step.illustration {
        case .bloom:
            BloomIllustration()
        case .quote:
            QuoteIllustration()
        case .formula:
            FormulaIllustration()
        case .flames:
            FlameTypesIllustration()
        case .levers:
            LeversIllustration()
        case .appOverview:
            AppOverviewIllustration()
        case .privacy:
            PrivacyIllustration()
        case .ready:
            ReadyIllustration()
        }
    }
}

private struct WalkthroughCopy: View {
    let step: WalkthroughStep

    var body: some View {
        VStack(spacing: 12) {
            if let eyebrow = step.eyebrow {
                Text(eyebrow.uppercased())
                    .font(.caption2.weight(.semibold))
                    .tracking(1.1)
                    .foregroundStyle(AppDesign.accentText)
            }

            Text(step.title)
                .font(.system(size: 30, weight: .semibold, design: .serif))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.82)

            Text(step.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct WalkthroughPagination: View {
    let total: Int
    let current: Int

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index == current ? AppDesign.accent : Color.secondary.opacity(0.24))
                    .frame(width: index == current ? 22 : 6, height: 6)
            }
        }
        .animation(.snappy(duration: 0.22), value: current)
        .accessibilityLabel("Step \(current + 1) of \(total)")
    }
}

private struct WalkthroughPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(AppDesign.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
    }
}

private struct WalkthroughSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .opacity(configuration.isPressed ? 0.58 : 1)
    }
}

private struct BloomIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(AppDesign.accentSoft)
                .frame(width: 190, height: 190)
                .blur(radius: 10)

            ForEach(0..<8, id: \.self) { index in
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(AppDesign.accent.opacity(index.isMultiple(of: 2) ? 0.88 : 0.46))
                    .frame(width: 54, height: 106)
                    .offset(y: -42)
                    .rotationEffect(.degrees(Double(index) * 45))
            }

            Circle()
                .fill(AppDesign.surface)
                .frame(width: 62, height: 62)
                .overlay {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(AppDesign.accent)
                }
                .shadow(color: .black.opacity(0.10), radius: 10, y: 6)
        }
    }
}

private struct QuoteIllustration: View {
    var body: some View {
        DesignCard(padding: 20, background: AppDesign.accentSoft) {
            Text("When your money makes more than you spend, you've reached freedom.")
                .font(.system(.body, design: .serif).italic())
                .lineSpacing(4)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 38)
    }
}

private struct FormulaIllustration: View {
    var body: some View {
        VStack(spacing: 10) {
            formulaCard(title: "Annual spending", value: "36,000")

            Image(systemName: "multiply")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppDesign.accent)

            formulaCard(title: "FIRE multiplier", value: "25")

            Image(systemName: "equal")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppDesign.accent)

            formulaCard(title: "FIRE number", value: "900,000", isResult: true)
        }
        .padding(.horizontal, 40)
    }

    private func formulaCard(title: String, value: String, isResult: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.headline.monospacedDigit())
                .foregroundStyle(isResult ? AppDesign.accentText : .primary)
        }
        .padding(.horizontal, 16)
        .frame(height: 44)
        .background(isResult ? AppDesign.accentSoft : AppDesign.surface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(isResult ? AppDesign.accent.opacity(0.28) : AppDesign.border, lineWidth: 0.5)
        }
    }
}

private struct FlameTypesIllustration: View {
    private let items = [("Lean", "Lower spend", 0.74), ("FIRE", "Balanced", 1.0), ("Fat", "More comfort", 1.24)]

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(items, id: \.0) { item in
                VStack(spacing: 10) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 38 * item.2, weight: .semibold))
                        .foregroundStyle(AppDesign.accent.opacity(item.2 == 1 ? 1 : 0.72))
                        .frame(height: 62)

                    Text(item.0)
                        .font(.headline)

                    Text(item.1)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 8)
                .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppDesign.border, lineWidth: 0.5)
                }
            }
        }
        .padding(.horizontal, 22)
    }
}

private struct LeversIllustration: View {
    var body: some View {
        VStack(spacing: 12) {
            leverCard(icon: "arrow.up.right", title: "Invest more", value: "Monthly habit", tint: AppDesign.accent)
            leverCard(icon: "arrow.down.right", title: "Spend less", value: "Lower FIRE number", tint: .orange)
        }
        .padding(.horizontal, 34)
    }

    private func leverCard(icon: String, title: String, value: String, tint: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(tint.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)
                Text(value)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppDesign.border, lineWidth: 0.5)
        }
    }
}

private struct AppOverviewIllustration: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Portfolio")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("128,420")
                        .font(.title3.weight(.semibold).monospacedDigit())
                }
                Spacer()
                Text("+12.4%")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppDesign.accentText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppDesign.accentSoft, in: Capsule())
            }

            ProgressLine(value: 0.42)
                .frame(height: 8)

            HStack(spacing: 10) {
                miniMetric("FIRE", "42%")
                miniMetric("Monthly", "1,000")
            }
        }
        .padding(18)
        .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppDesign.border, lineWidth: 0.5)
        }
        .padding(.horizontal, 34)
    }

    private func miniMetric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold).monospacedDigit())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppDesign.surfaceMuted, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct PrivacyIllustration: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 58, weight: .semibold))
                .foregroundStyle(AppDesign.accent)
                .frame(width: 104, height: 104)
                .background(AppDesign.accentSoft, in: Circle())

            VStack(spacing: 10) {
                privacyRow("SwiftData on device")
                privacyRow("No account required")
                privacyRow("You control every entry")
            }
            .padding(16)
            .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppDesign.border, lineWidth: 0.5)
            }
        }
        .padding(.horizontal, 38)
    }

    private func privacyRow(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppDesign.accent)
            Text(text)
                .font(.subheadline.weight(.medium))
            Spacer()
        }
    }
}

private struct ReadyIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(AppDesign.accentSoft)
                .frame(width: 250, height: 250)
                .blur(radius: 14)

            BloomIllustration()
                .scaleEffect(0.86)
        }
    }
}
