import SwiftData
import SwiftUI

struct HoldingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HoldingLot.ticker) private var holdings: [HoldingLot]
    @Query private var prices: [PriceSnapshot]

    @State private var expandedTickers: Set<String> = []

    var body: some View {
        NavigationStack {
            List {
                Section {
                    holdingsSummary
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }

                Section {
                    ForEach(positions) { position in
                        PositionAccordionRow(
                            position: position,
                            isExpanded: expandedTickers.contains(position.ticker),
                            onToggle: { toggle(position.ticker) },
                            onDelete: deleteHolding
                        )
                    }
                } header: {
                    Text("\(positions.count) positions · \(holdings.count) transactions")
                } footer: {
                    Text("Tap a ticker to see buy entries. Swipe an entry to delete it.")
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(AppDesign.background)
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

    private var metric: PortfolioMetric {
        PortfolioCalculator.metrics(holdings: holdings, prices: prices)
    }

    private var positions: [HoldingPosition] {
        let priceMap = Dictionary(uniqueKeysWithValues: prices.map { ($0.ticker, $0.price) })
        let grouped = Dictionary(grouping: holdings, by: \.ticker)

        return grouped
            .map { ticker, lots in
                HoldingPosition(ticker: ticker, lots: lots, latestPrice: priceMap[ticker])
            }
            .sorted { $0.currentValue > $1.currentValue }
    }

    private var holdingsSummary: some View {
        DesignCard(padding: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    SectionLabel(title: "Total invested")
                    Text(metric.invested, format: .portfolioCurrency)
                        .font(.title3.weight(.semibold))
                        .monospacedDigit()
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    SectionLabel(title: "Current")
                    Text(metric.currentValue, format: .portfolioCurrency)
                        .font(.title3.weight(.semibold))
                        .monospacedDigit()
                }
            }
        }
    }

    private func toggle(_ ticker: String) {
        if expandedTickers.contains(ticker) {
            expandedTickers.remove(ticker)
        } else {
            expandedTickers.insert(ticker)
        }
    }

    private func deleteHolding(_ holding: HoldingLot) {
        modelContext.delete(holding)
        try? modelContext.save()
    }
}

private struct HoldingPosition: Identifiable {
    let ticker: String
    let name: String
    let lots: [HoldingLot]
    let latestPrice: Decimal?

    var id: String { ticker }

    init(ticker: String, lots: [HoldingLot], latestPrice: Decimal?) {
        self.ticker = ticker
        self.lots = lots.sorted { $0.purchaseDate < $1.purchaseDate }
        self.latestPrice = latestPrice
        name = lots.first?.name ?? ticker
    }

    var invested: Decimal {
        lots.reduce(.zero) { $0 + $1.invested }
    }

    var shares: Decimal {
        lots.reduce(.zero) { $0 + $1.shareCount }
    }

    var averageCost: Decimal {
        shares == 0 ? 0 : invested / shares
    }

    var currentValue: Decimal {
        guard let latestPrice else { return invested }
        return shares * latestPrice
    }

    var gain: Decimal {
        guard latestPrice != nil else { return 0 }
        return currentValue - invested
    }

    var gainPercent: Decimal {
        invested == 0 ? 0 : gain / invested
    }

    var hasLatestPrice: Bool {
        latestPrice != nil
    }

    var isin: String? {
        lots.compactMap(\.isin).first
    }
}

private struct PositionAccordionRow: View {
    let position: HoldingPosition
    let isExpanded: Bool
    let onToggle: () -> Void
    let onDelete: (HoldingLot) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(position.ticker)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)

                            Text(position.name)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Text("\(position.shares.formatted()) sh · avg \(position.averageCost.formatted(.portfolioCurrency)) · \(position.lots.count) \(position.lots.count == 1 ? "buy" : "buys")")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)

                        if let isin = position.isin {
                            Text(isin)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        Text(position.currentValue, format: .portfolioCurrency)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .monospacedDigit()

                        Text(position.hasLatestPrice ? position.gainPercent.formatted(.portfolioPercent) : "Refresh price")
                            .font(.caption)
                            .foregroundStyle(position.gain >= 0 ? AppDesign.positive : AppDesign.negative)
                            .monospacedDigit()
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .padding(.top, 3)
                }
                .contentShape(Rectangle())
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()

                VStack(spacing: 0) {
                    transactionHeader

                    ForEach(position.lots) { lot in
                        NavigationLink {
                            HoldingDetailView(holding: lot, latestPrice: position.latestPrice)
                        } label: {
                            TransactionRow(holding: lot, latestPrice: position.latestPrice)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                onDelete(lot)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }

                        if lot.id != position.lots.last?.id {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }

                    ValueRow(title: "Avg cost / share", value: position.averageCost.formatted(.portfolioCurrency), valueColor: .primary)
                        .padding(.top, 8)
                }
                .padding(.top, 8)
                .padding(.bottom, 4)
                .background(AppDesign.surfaceMuted)
            }
        }
    }

    private var transactionHeader: some View {
        HStack {
            Text("Date")
            Spacer()
            Text("Shares @ price")
            Text("Invested")
                .frame(minWidth: 70, alignment: .trailing)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(.secondary)
        .textCase(.uppercase)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
    }
}

private struct TransactionRow: View {
    let holding: HoldingLot
    let latestPrice: Decimal?

    private var performance: HoldingPerformance {
        HoldingPerformance(holding: holding, latestPrice: latestPrice)
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(holding.purchaseDate, format: .dateTime.day().month(.abbreviated).year())
                .font(.caption)
                .foregroundStyle(.primary)
                .frame(minWidth: 78, alignment: .leading)

            Spacer(minLength: 8)

            Text("\(holding.shareCount.formatted()) @ \(holding.boughtAt.formatted(.portfolioCurrency))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            VStack(alignment: .trailing, spacing: 2) {
                Text(holding.invested, format: .portfolioCurrency)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)

                Text(performance.hasLatestPrice ? performance.unrealizedGainPercent.formatted(.portfolioPercent) : "No price")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(performance.unrealizedGain >= 0 ? AppDesign.positive : AppDesign.negative)
            }
            .frame(minWidth: 72, alignment: .trailing)
        }
        .monospacedDigit()
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}
