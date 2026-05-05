import SwiftData
import SwiftUI

struct LiquidateEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let holding: HoldingLot
    let latestPrice: Decimal?
    let liquidations: [LiquidationLot]

    @State private var soldShares: String
    @State private var soldAt: String
    @State private var saleDate = Date.now

    init(holding: HoldingLot, latestPrice: Decimal?, liquidations: [LiquidationLot]) {
        self.holding = holding
        self.latestPrice = latestPrice
        self.liquidations = liquidations

        let remainingShares = LiquidationCalculator.remainingShares(for: holding, liquidations: liquidations)
        _soldShares = State(initialValue: remainingShares.formatted())
        _soldAt = State(initialValue: (latestPrice ?? holding.boughtAt).rounded(scale: 2).formatted())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    formSection("Sale") {
                        inputRow("Shares sold", text: $soldShares, placeholder: "10", keyboard: .decimalPad)
                        Divider()
                        inputRow("Sold at", text: $soldAt, placeholder: "140", suffix: PortfolioCurrency.selected.rawValue, keyboard: .decimalPad)
                    }

                    formSection("Date") {
                        DatePicker("Sold on", selection: $saleDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }

                    previewCard

                    Button {
                        saveLiquidation()
                    } label: {
                        Label("Record liquidation", systemImage: "arrow.left.arrow.right.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppDesign.accent)
                    .disabled(!isValid)
                }
                .padding()
            }
            .background(AppDesign.background)
            .navigationTitle("Liquidate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }

    private var remainingShares: Decimal {
        LiquidationCalculator.remainingShares(for: holding, liquidations: liquidations)
    }

    private var sharesValue: Decimal {
        decimal(from: soldShares) ?? 0
    }

    private var salePriceValue: Decimal {
        decimal(from: soldAt) ?? 0
    }

    private var proceeds: Decimal {
        sharesValue * salePriceValue
    }

    private var costBasis: Decimal {
        LiquidationCalculator.costBasis(for: holding, shares: sharesValue)
    }

    private var realizedGain: Decimal {
        proceeds - costBasis
    }

    private var isValid: Bool {
        sharesValue > 0 &&
            sharesValue <= remainingShares &&
            salePriceValue >= 0
    }

    private var previewCard: some View {
        DesignCard(padding: 14, background: AppDesign.accentSoft) {
            VStack(alignment: .leading, spacing: 10) {
                Text("PREVIEW")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppDesign.accentText)
                    .tracking(0.4)

                ValueRow(title: "Remaining before sale", value: remainingShares.formatted())
                ValueRow(title: "Sale proceeds", value: proceeds.formatted(.portfolioCurrency), valueColor: .primary)
                ValueRow(title: "Cost basis", value: costBasis.formatted(.portfolioCurrency))
                ValueRow(title: realizedGain >= 0 ? "Realized gain" : "Realized loss", value: realizedGain.formatted(.portfolioCurrency), valueColor: realizedGain >= 0 ? AppDesign.positive : AppDesign.negative)
            }
        }
    }

    private func formSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(title: title)

            DesignCard(padding: 0) {
                VStack(spacing: 0) {
                    content()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }
        }
    }

    private func inputRow(
        _ title: String,
        text: Binding<String>,
        placeholder: String,
        suffix: String? = nil,
        keyboard: UIKeyboardType
    ) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .frame(minWidth: 96, alignment: .leading)

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .multilineTextAlignment(.trailing)
                .monospacedDigit()

            if let suffix {
                Text(suffix)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minHeight: 46)
    }

    private func saveLiquidation() {
        guard isValid else { return }

        let liquidation = LiquidationLot(
            holdingID: holding.id,
            ticker: holding.ticker,
            name: holding.name,
            soldShares: sharesValue,
            soldAt: salePriceValue,
            proceeds: proceeds,
            costBasis: costBasis,
            saleDate: saleDate
        )

        modelContext.insert(liquidation)
        try? modelContext.save()
        dismiss()
    }

    private func decimal(from value: String) -> Decimal? {
        Decimal.clean(value).flatMap { $0 >= 0 ? $0 : nil }
    }
}
