import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Local data") {
                    Label("Holdings are stored with SwiftData on this device.", systemImage: "internaldrive")
                    Label("Entries are added manually and never leave the device.", systemImage: "square.and.pencil")
                }

                Section("Market prices") {
                    Label("Refreshing prices contacts the quote provider with ticker symbols only.", systemImage: "network")
                    Label("Invested amounts, share counts, and performance calculations stay on device.", systemImage: "lock")
                }
            }
            .navigationTitle("Privacy")
        }
    }
}
