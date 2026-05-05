import SwiftData
import SwiftUI

struct FIREPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [FIREProfile]
    @Query(sort: \HoldingLot.purchaseDate) private var holdings: [HoldingLot]
    @Query private var liquidations: [LiquidationLot]
    @Query private var prices: [PriceSnapshot]

    @State private var profile = FIREProfile()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    summary
                    habitCard
                    assumptions
                }
                .padding()
            }
            .background(AppDesign.background)
            .navigationTitle("FIRE Calculator")
            .onAppear(perform: loadProfile)
            .onChange(of: profile.currentAge) { saveProfile() }
            .onChange(of: profile.annualIncome) { saveProfile() }
            .onChange(of: profile.monthlyInvestment) { saveProfile() }
            .onChange(of: profile.targetAnnualSpend) { saveProfile() }
            .onChange(of: profile.investmentRate) { saveProfile() }
            .onChange(of: profile.expectedAnnualReturn) { saveProfile() }
            .onChange(of: profile.safeWithdrawalRate) { saveProfile() }
            .onChange(of: profile.planStartDate) { saveProfile() }
        }
    }

    private var metric: PortfolioMetric {
        PortfolioCalculator.metrics(holdings: holdings, prices: prices, liquidations: liquidations)
    }

    private var plan: FIREPlan {
        FIRECalculator.plan(profile: profile, portfolioValue: metric.currentValue)
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel(title: "Estimated FIRE date")

            Text(plan.fireDate.map { "FIRE in \($0, format: .dateTime.year().month())" } ?? "Set a monthly investment")
                .font(.system(.title, design: .rounded, weight: .bold))
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            ProgressLine(value: plan.progress.doubleValue, tint: plan.isOnTrack ? AppDesign.positive : AppDesign.accent)
                .accessibilityLabel("FIRE progress")

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FIRE number")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(plan.fireNumber, format: .portfolioCurrency)
                        .font(.title2.bold())
                        .monospacedDigit()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("FIRE age")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Text(plan.fireAge.map(String.init) ?? "-")
                        .font(.title2.bold())
                        .monospacedDigit()
                }
            }

            Text("You are \(plan.progress, format: .portfolioPercent) of the way there with \(metric.currentValue, format: .portfolioCurrency) invested.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous)
                .stroke(AppDesign.border, lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }

    private var habitCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Monthly habit", systemImage: "repeat.circle.fill")
                .font(.headline)

            MetricCard(
                title: monthlyHabitRemaining > 0 ? "Invest this month" : "This month done",
                value: habitCardValue.formatted(.portfolioCurrency),
                subtitle: habitCardSubtitle,
                systemImage: monthlyHabitRemaining > 0 ? "plus.circle" : "checkmark.seal",
                tint: monthlyHabitRemaining > 0 ? .orange : .green
            )

            VStack(alignment: .leading, spacing: 6) {
                ProgressLine(value: monthlyHabitProgress.doubleValue, tint: monthlyHabitRemaining > 0 ? .orange : AppDesign.positive)
                    .frame(height: 8)
                    .accessibilityLabel("Monthly habit progress")
                    .accessibilityValue(monthlyHabitProgress.formatted(.portfolioPercent))

                HStack {
                    Text(monthlyHabitProgress.formatted(.portfolioPercent))
                    Spacer()
                    Text("\(investedThisMonth.formatted(.portfolioCurrency)) / \(plan.monthlyInvestment.formatted(.portfolioCurrency))")
                }
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
            }

            ValueRow(title: "Monthly habit target", value: plan.monthlyInvestment.formatted(.portfolioCurrency))
            ValueRow(title: "Invested this month", value: investedThisMonth.formatted(.portfolioCurrency))
            ValueRow(title: "Remaining this month", value: monthlyHabitRemaining.formatted(.portfolioCurrency))
            ValueRow(title: "Required monthly", value: plan.targetMonthlyInvestment.formatted(.portfolioCurrency))
            ValueRow(title: "Actual invested", value: metric.invested.formatted(.portfolioCurrency))
            ValueRow(title: "Invested since start", value: investedSinceTrackingStart.formatted(.portfolioCurrency))
            ValueRow(title: "Tracked months", value: "\(trackedMonths)")
        }
        .padding(16)
        .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous)
                .stroke(AppDesign.border, lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }

    private var assumptions: some View {
        VStack(alignment: .leading, spacing: 18) {
            SectionLabel(title: "Plan inputs")

            stepperRow("Age", value: $profile.currentAge, range: 16...90)

            valueSlider(
                title: "Annual income",
                value: $profile.annualIncome,
                range: 0...500_000,
                step: 1_000,
                format: .portfolioCurrency
            )

            valueSlider(
                title: "Monthly investment",
                value: $profile.monthlyInvestment,
                range: 0...20_000,
                step: 50,
                format: .portfolioCurrency
            )

            valueSlider(
                title: "Target yearly spend",
                value: $profile.targetAnnualSpend,
                range: 0...250_000,
                step: 500,
                format: .portfolioCurrency
            )

            percentSlider("Investment rate", value: $profile.investmentRate, range: 0...0.9)
            percentSlider("Expected return", value: $profile.expectedAnnualReturn, range: 0...0.14)
            percentSlider("Withdrawal rate", value: $profile.safeWithdrawalRate, range: 0.02...0.06)

            DatePicker("Tracking since", selection: $profile.planStartDate, displayedComponents: .date)
                .datePickerStyle(.compact)

            Button {
                profile.monthlyInvestment = FIRECalculator.monthlyInvestment(from: profile.annualIncome, investmentRate: profile.investmentRate)
                saveProfile()
            } label: {
                Label("Use income rate", systemImage: "wand.and.sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(16)
        .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous)
                .stroke(AppDesign.border, lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }

    private var habitCardValue: Decimal {
        monthlyHabitRemaining > 0 ? monthlyHabitRemaining : investedThisMonth
    }

    private var habitCardSubtitle: String {
        guard plan.monthlyInvestment > 0 else {
            return "Set a monthly investment target to track the habit."
        }

        if monthlyHabitRemaining > 0 {
            return "You have logged \(investedThisMonth.formatted(.portfolioCurrency)) of your \(plan.monthlyInvestment.formatted(.portfolioCurrency)) monthly habit."
        }

        return "You have reached this month's habit target."
    }

    private var investedThisMonth: Decimal {
        let interval = Calendar.current.dateInterval(of: .month, for: .now)
        guard let interval else { return 0 }

        return holdings
            .filter { $0.purchaseDate >= interval.start && $0.purchaseDate < interval.end }
            .reduce(Decimal.zero) { $0 + $1.invested }
    }

    private var monthlyHabitRemaining: Decimal {
        max(plan.monthlyInvestment - investedThisMonth, 0)
    }

    private var monthlyHabitProgress: Decimal {
        guard plan.monthlyInvestment > 0 else { return 0 }
        return min(investedThisMonth / plan.monthlyInvestment, 1)
    }

    private var investedSinceTrackingStart: Decimal {
        let startDate = Calendar.current.startOfDay(for: profile.planStartDate)
        return holdings
            .filter { $0.purchaseDate >= startDate }
            .reduce(Decimal.zero) { $0 + $1.invested }
    }

    private var trackedMonths: Int {
        guard investedSinceTrackingStart > 0 else { return 0 }

        let calendar = Calendar.current
        guard
            let startMonth = calendar.dateInterval(of: .month, for: profile.planStartDate)?.start,
            let currentMonth = calendar.dateInterval(of: .month, for: .now)?.start
        else {
            return 0
        }

        let elapsedMonths = calendar.dateComponents([.month], from: startMonth, to: currentMonth).month ?? 0
        return max(elapsedMonths + 1, 1)
    }

    private func stepperRow(_ title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        Stepper(value: value, in: range) {
            LabeledContent(title, value: "\(value.wrappedValue)")
        }
    }

    private func valueSlider<F: FormatStyle>(
        title: String,
        value: Binding<Decimal>,
        range: ClosedRange<Double>,
        step: Double,
        format: F
    ) -> some View where F.FormatInput == Decimal, F.FormatOutput == String {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent(title, value: value.wrappedValue.formatted(format))
                .monospacedDigit()
            Slider(value: value.doubleValue, in: range, step: step)
                .tint(AppDesign.accent)
        }
    }

    private func percentSlider(_ title: String, value: Binding<Decimal>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent(title, value: value.wrappedValue.formatted(.portfolioPercent))
                .monospacedDigit()
            Slider(value: value.doubleValue, in: range, step: 0.005)
                .tint(AppDesign.accent)
        }
    }

    private func loadProfile() {
        let defaultStartDate = holdings.map(\.purchaseDate).min() ?? .now

        if let stored = profiles.first {
            profile = stored
            if shouldBackfillStartDate(profile.planStartDate, defaultStartDate: defaultStartDate) {
                profile.planStartDate = defaultStartDate
                saveProfile()
            }
        } else {
            profile.planStartDate = defaultStartDate
            modelContext.insert(profile)
            try? modelContext.save()
        }
    }

    private func saveProfile() {
        profile.updatedAt = .now
        try? modelContext.save()
    }

    private func shouldBackfillStartDate(_ currentStartDate: Date, defaultStartDate: Date) -> Bool {
        guard defaultStartDate < currentStartDate else { return false }

        let trackedMonths = Calendar.current.dateComponents([.month], from: currentStartDate, to: .now).month ?? 0
        return trackedMonths == 0
    }
}
