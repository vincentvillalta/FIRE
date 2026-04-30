import SwiftData
import SwiftUI

struct AddEntryView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var ticker = ""
    @State private var name = ""
    @State private var invested = ""
    @State private var boughtAt = ""
    @State private var amountOfStocks = ""
    @State private var purchaseDate = Date.now
    @State private var savedMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Investment") {
                    TextField("Ticker", text: $ticker)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()

                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)

                    TextField("Invested (EUR)", text: $invested)
                        .keyboardType(.decimalPad)

                    TextField("Bought at", text: $boughtAt)
                        .keyboardType(.decimalPad)

                    TextField("Amount of stocks", text: $amountOfStocks)
                        .keyboardType(.decimalPad)

                    DatePicker("Date", selection: $purchaseDate, displayedComponents: .date)
                }

                Section {
                    Button {
                        saveEntry()
                    } label: {
                        Label("Add entry", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!isValid)
                }

                if let savedMessage {
                    Section {
                        Label(savedMessage, systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .navigationTitle("Add Entry")
        }
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
