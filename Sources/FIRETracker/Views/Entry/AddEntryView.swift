import SwiftData
import SwiftUI

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var ticker = ""
    @State private var isin = ""
    @State private var name = ""
    @State private var invested = ""
    @State private var boughtAt = ""
    @State private var amountOfStocks = ""
    @State private var purchaseDate = Date.now
    @State private var savedMessage: String?

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

                    Button {
                        saveEntry()
                    } label: {
                        Label("Add entry", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppDesign.accent)
                    .disabled(!isValid)

                    if let savedMessage {
                        Label(savedMessage, systemImage: "checkmark.circle.fill")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppDesign.positive)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding()
            }
            .background(AppDesign.background)
            .navigationTitle("New Entry")
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

    private func saveEntry() {
        guard
            let investedValue = decimal(from: invested),
            let boughtAtValue = decimal(from: boughtAt),
            let amountValue = decimal(from: amountOfStocks)
        else {
            return
        }

        let holding = HoldingLot(
            ticker: ticker.trimmingCharacters(in: .whitespacesAndNewlines),
            isin: isin.trimmingCharacters(in: .whitespacesAndNewlines),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            invested: investedValue,
            boughtAt: boughtAtValue,
            shareCount: amountValue,
            purchaseDate: purchaseDate
        )
        modelContext.insert(holding)
        try? modelContext.save()

        savedMessage = "\(holding.ticker) added"
        resetForm()
    }

    private func resetForm() {
        ticker = ""
        isin = ""
        name = ""
        invested = ""
        boughtAt = ""
        amountOfStocks = ""
        purchaseDate = .now
    }

    private func decimal(from value: String) -> Decimal? {
        Decimal.clean(value).flatMap { $0 >= 0 ? $0 : nil }
    }
}
