import SwiftData
import SwiftUI

struct FIREPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [FIREProfile]
    @Query(sort: \HoldingLot.purchaseDate) private var holdings: [HoldingLot]
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
            .background(Color(.systemGroupedBackground))
            .navigationTitle("FIRE Plan")
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
        PortfolioCalculator.metrics(holdings: holdings, prices: prices)
    }

    private var plan: FIREPlan {
        FIRECalculator.plan(profile: profile, portfolioValue: metric.currentValue)
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(plan.fireDate.map { "FIRE in \($0, format: .dateTime.year().month())" } ?? "Set a monthly investment")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            ProgressView(value: plan.progress.doubleValue)
                .tint(plan.isOnTrack ? .green : .teal)
                .accessibilityLabel("FIRE progress")

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("FIRE number")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(plan.fireNumber, format: .portfolioCurrency)
                        .font(.title2.bold())
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("FIRE age")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(plan.fireAge.map(String.init) ?? "-")
                        .font(.title2.bold())
                }
            }

            Text("You are \(plan.progress, format: .portfolioPercent) of the way there with \(metric.currentValue, format: .portfolioCurrency) invested.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(22)
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var habitCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Monthly habit", systemImage: "repeat.circle.fill")
                .font(.headline)

            MetricCard(
                title: plan.isOnTrack ? "Keep investing" : "Increase by",
                value: abs(plan.monthlyGap).formatted(.portfolioCurrency),
                subtitle: plan.isOnTrack ? "Current monthly habit reaches the target." : "Monthly gap to close based on your current trajectory.",
                systemImage: plan.isOnTrack ? "checkmark.seal" : "plus.circle",
                tint: plan.isOnTrack ? .green : .orange
            )

            LabeledContent("Monthly investment", value: plan.monthlyInvestment.formatted(.portfolioCurrency))
            LabeledContent("Invested since start", value: plan.investedSinceStart.formatted(.portfolioCurrency))
            LabeledContent("Tracked months", value: "\(plan.monthsSinceStart)")
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var assumptions: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Plan inputs")
                .font(.headline)

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
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
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
            Slider(value: value.doubleValue, in: range, step: step)
        }
    }

    private func percentSlider(_ title: String, value: Binding<Decimal>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            LabeledContent(title, value: value.wrappedValue.formatted(.portfolioPercent))
            Slider(value: value.doubleValue, in: range, step: 0.005)
        }
    }

    private func loadProfile() {
        if let stored = profiles.first {
            profile = stored
        } else {
            modelContext.insert(profile)
            try? modelContext.save()
        }
    }

    private func saveProfile() {
        profile.updatedAt = .now
        try? modelContext.save()
    }
}
