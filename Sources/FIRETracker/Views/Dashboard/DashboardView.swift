import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HoldingLot.purchaseDate) private var holdings: [HoldingLot]
    @Query private var prices: [PriceSnapshot]

    @State private var isRefreshing = false
    @State private var refreshError: String?

    private let quoteService: QuoteService = YahooQuoteService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    hero
                    metricsGrid
                    projections
                    holdingsPreview
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("FIRE Tracker")
            .toolbar {
                Button {
                    Task { await refreshQuotes() }
                } label: {
                    if isRefreshing {
                        ProgressView()
                    } else {
                        Label("Refresh prices", systemImage: "arrow.clockwise")
                    }
                }
                .disabled(isRefreshing || holdings.isEmpty)
            }
            .alert("Could not refresh prices", isPresented: .constant(refreshError != nil)) {
                Button("OK") { refreshError = nil }
            } message: {
                Text(refreshError ?? "")
            }
        }
    }

    private var metric: PortfolioMetric {
        PortfolioCalculator.metrics(holdings: holdings, prices: prices)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(heroTitle)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(metric.gain, format: .portfolioCurrency)
                .font(.system(size: 54, weight: .bold, design: .rounded))
                .foregroundStyle(metric.isPositive ? .green : .orange)
                .lineLimit(1)
                .minimumScaleFactor(0.55)

            Text(heroSubtitle)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 18, y: 10)
        }
    }

    private var heroTitle: String {
        if metric.hasMissingPrices {
            return "Refresh prices to see growth."
        }

        return metric.isPositive ? "Your money is working." : "Your plan is still compounding."
    }

    private var heroSubtitle: String {
        if metric.hasMissingPrices {
            return "\(metric.missingPriceCount) holding\(metric.missingPriceCount == 1 ? "" : "s") still need today prices. Tickers only are sent to the quote provider."
        }

        return "Unrealized \(metric.gainPercent.formatted(.portfolioPercent)) on \(metric.invested.formatted(.portfolioCurrency)) invested."
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
            MetricCard(
                title: "Current value",
                value: metric.currentValue.formatted(.portfolioCurrency),
                subtitle: "Based on latest fetched prices",
                systemImage: "banknote",
                tint: .teal
            )

            MetricCard(
                title: "Invested",
                value: metric.invested.formatted(.portfolioCurrency),
                subtitle: "Cash you put to work",
                systemImage: "tray.and.arrow.down",
                tint: .blue
            )

            MetricCard(
                title: "Annualized",
                value: (metric.annualizedReturn ?? 0).formatted(.portfolioPercent),
                subtitle: "Since your earliest lot",
                systemImage: "calendar.badge.clock",
                tint: .purple
            )
        }
    }

    private var projections: some View {
        let annualGrowth = Decimal(string: "0.07") ?? 0.07
        let points = PortfolioCalculator.projections(from: metric.currentValue, annualGrowth: annualGrowth)

        return NavigationLink {
            ProjectionDetailView(currentValue: metric.currentValue, annualGrowth: annualGrowth, points: points)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Future projection")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }

                ProjectionChart(points: points)
                    .allowsHitTesting(false)

                Text("Uses a 7% annual growth assumption. Tap for detail.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var holdingsPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Largest positions")
                .font(.headline)

            if holdings.isEmpty {
                ContentUnavailableView("Add your first entry", systemImage: "doc.badge.plus", description: Text("Your holdings stay in SwiftData on this device."))
            } else {
                ForEach(holdings.prefix(5)) { holding in
                    HoldingRow(holding: holding, latestPrice: prices.first { $0.ticker == holding.ticker }?.price)
                }
            }
        }
        .padding(16)
        .background(.background, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @MainActor
    private func refreshQuotes() async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let tickers = Array(Set(holdings.map(\.ticker)))
            let quotes = try await quoteService.fetchQuotes(for: tickers)
            for quote in quotes {
                if let snapshot = prices.first(where: { $0.ticker == quote.ticker }) {
                    snapshot.price = quote.price
                    snapshot.fetchedAt = quote.fetchedAt
                } else {
                    modelContext.insert(PriceSnapshot(ticker: quote.ticker, price: quote.price, fetchedAt: quote.fetchedAt))
                }
            }
            try modelContext.save()
        } catch {
            refreshError = error.localizedDescription
        }
    }
}
