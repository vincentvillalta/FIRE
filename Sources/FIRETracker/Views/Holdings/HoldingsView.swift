import SwiftData
import SwiftUI

struct HoldingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HoldingLot.ticker) private var holdings: [HoldingLot]
    @Query private var prices: [PriceSnapshot]

    var body: some View {
        NavigationStack {
            List {
                ForEach(holdings) { holding in
                    NavigationLink {
                        HoldingDetailView(holding: holding, latestPrice: prices.first { $0.ticker == holding.ticker }?.price)
                    } label: {
                        HoldingRow(holding: holding, latestPrice: prices.first { $0.ticker == holding.ticker }?.price)
                    }
                }
                .onDelete(perform: deleteHoldings)
            }
            .overlay {
                if holdings.isEmpty {
                    ContentUnavailableView("No holdings yet", systemImage: "briefcase", description: Text("Add an entry to start tracking your retirement plan."))
                }
            }
            .navigationTitle("Holdings")
            .toolbar {
                EditButton()
            }
        }
    }

    private func deleteHoldings(at offsets: IndexSet) {
        for offset in offsets {
            modelContext.delete(holdings[offset])
        }
        try? modelContext.save()
    }
}
