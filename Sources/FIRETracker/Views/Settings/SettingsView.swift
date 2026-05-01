import SwiftUI

struct SettingsView: View {
    @AppStorage(UserDefaultsKey.portfolioCurrency) private var selectedCurrencyCode = PortfolioCurrency.selected.rawValue

    var body: some View {
        NavigationStack {
            List {
                Section("Currency") {
                    Picker("Portfolio currency", selection: $selectedCurrencyCode) {
                        ForEach(PortfolioCurrency.allCases) { currency in
                            Text("\(currency.rawValue) - \(currency.name)")
                                .tag(currency.rawValue)
                        }
                    }

                    Text("The app supports one portfolio currency at a time. Price refresh prioritizes Yahoo market symbols that trade in the selected currency.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Local data") {
                    Label("Holdings are stored with SwiftData on this device.", systemImage: "internaldrive")
                    Label("Entries are added manually and never leave the device.", systemImage: "square.and.pencil")
                }

                Section("Market prices") {
                    Label("Refreshing prices contacts the quote provider with ticker symbols and optional ISINs only.", systemImage: "network")
                    Label("Invested amounts, share counts, and performance calculations stay on device.", systemImage: "lock")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppDesign.background)
            .navigationTitle("Privacy")
        }
    }
}
