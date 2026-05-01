import SwiftData
import SwiftUI

struct EditEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let holding: HoldingLot

    @State private var ticker: String
    @State private var isin: String
    @State private var name: String
    @State private var invested: String
    @State private var boughtAt: String
    @State private var amountOfStocks: String
    @State private var purchaseDate: Date

    init(holding: HoldingLot) {
        self.holding = holding
        _ticker = State(initialValue: holding.ticker)
        _isin = State(initialValue: holding.isin ?? "")
        _name = State(initialValue: holding.name)
        _invested = State(initialValue: holding.invested.formatted(.number))
        _boughtAt = State(initialValue: holding.boughtAt.formatted(.number))
        _amountOfStocks = State(initialValue: holding.shareCount.formatted(.number))
        _purchaseDate = State(initialValue: holding.purchaseDate)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    formSection("Instrument") {
                        inputRow("Ticker", text: $ticker, placeholder: "VWCE", keyboard: .default)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()

                        Divider()

                        inputRow("ISIN", text: $isin, placeholder: "IE00B5BMR087", keyboard: .default)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()

                        Divider()

                        inputRow("Name", text: $name, placeholder: "Vanguard FTSE All-World", keyboard: .default)
                            .textInputAutocapitalization(.words)
                    }

                    formSection("Position") {
                        inputRow("Invested", text: $invested, placeholder: "1500", suffix: "EUR", keyboard: .decimalPad)
                        Divider()
                        inputRow("Bought at", text: $boughtAt, placeholder: "124.50", suffix: "EUR", keyboard: .decimalPad)
                        Divider()
                        inputRow("Shares", text: $amountOfStocks, placeholder: "12.05", keyboard: .decimalPad)
                    }

                    formSection("Date") {
                        DatePicker("Bought on", selection: $purchaseDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }

                    previewCard
                }
                .padding()
            }
            .background(AppDesign.background)
            .navigationTitle("Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!isValid)
                }
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
                .frame(minWidth: 82, alignment: .leading)

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

    private var previewCard: some View {
        DesignCard(padding: 14, background: AppDesign.accentSoft) {
            VStack(alignment: .leading, spacing: 6) {
                Text("PREVIEW")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppDesign.accentText)
                    .tracking(0.4)

                Text(previewText)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineSpacing(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var previewText: String {
        let shareText = amountOfStocks.isEmpty ? "0" : amountOfStocks
        let tickerText = ticker.isEmpty ? "ticker" : ticker.uppercased()
        let boughtAtValue = decimal(from: boughtAt) ?? 0
        let investedValue = decimal(from: invested) ?? 0
        return "\(shareText) shares of \(tickerText) at \(boughtAtValue.formatted(.portfolioCurrency)) = \(investedValue.formatted(.portfolioCurrency)) invested."
    }

    private var isValid: Bool {
        !ticker.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            decimal(from: invested) != nil &&
            decimal(from: boughtAt) != nil &&
            decimal(from: amountOfStocks) != nil
    }

    private func save() {
        guard
            let investedValue = decimal(from: invested),
            let boughtAtValue = decimal(from: boughtAt),
            let amountValue = decimal(from: amountOfStocks)
        else {
            return
        }

        holding.ticker = ticker.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        holding.isin = isin.trimmingCharacters(in: .whitespacesAndNewlines).uppercased().nilIfEmpty
        holding.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        holding.invested = investedValue
        holding.boughtAt = boughtAtValue
        holding.shareCount = amountValue
        holding.purchaseDate = purchaseDate
        holding.importedAt = .now

        try? modelContext.save()
        dismiss()
    }

    private func decimal(from value: String) -> Decimal? {
        Decimal.clean(value).flatMap { $0 >= 0 ? $0 : nil }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
