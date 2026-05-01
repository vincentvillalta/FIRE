import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \HoldingLot.purchaseDate) private var holdings: [HoldingLot]
    @Query private var prices: [PriceSnapshot]
    @Query private var profiles: [FIREProfile]

    @AppStorage(UserDefaultsKey.portfolioCurrency) private var selectedCurrencyCode = PortfolioCurrency.selected.rawValue

    @State private var isRefreshing = false
    @State private var toast: ToastMessage?

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
            .background(AppDesign.background)
            .navigationTitle("Overview")
            .overlay(alignment: .bottom) {
                if let toast {
                    ToastBanner(toast: toast)
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
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
        }
    }

    private var metric: PortfolioMetric {
        PortfolioCalculator.metrics(holdings: holdings, prices: prices)
    }

    private var fireProfile: FIREProfile {
        profiles.first ?? FIREProfile()
    }

    private var firePlan: FIREPlan {
        FIRECalculator.plan(profile: fireProfile, portfolioValue: metric.currentValue)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(metric.isPositive ? AppDesign.positive : .orange)
                    .frame(width: 6, height: 6)

                Text(metric.hasMissingPrices ? "Prices needed" : "On track")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppDesign.accentText)
                    .tracking(0.4)
                    .textCase(.uppercase)
            }

            Text(heroTitle)
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
                .lineSpacing(2)

            ProgressLine(value: firePlan.progress.doubleValue)

            HStack {
                Text(metric.currentValue, format: .portfolioCurrency)
                Spacer()
                Text(firePlan.fireNumber, format: .portfolioCurrency)
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppDesign.accentSoft, in: RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous)
                .stroke(AppDesign.border, lineWidth: 0.5)
        }
    }

    private var heroTitle: String {
        if metric.hasMissingPrices {
            return "\(metric.missingPriceCount) holding\(metric.missingPriceCount == 1 ? "" : "s") need today prices. Tickers only are sent to the quote provider."
        }

        return "You are \(firePlan.progress.formatted(.portfolioPercent)) of the way to Regular FIRE. Steady contributions are doing the work."
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
            MetricCard(
                title: "Current value",
                value: metric.currentValue.formatted(.portfolioCurrency),
                subtitle: metric.hasMissingPrices ? "Some prices need refresh" : "\(metric.gain.formatted(.portfolioCurrency)) all time",
                systemImage: "banknote",
                tint: AppDesign.accent
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
                tint: AppDesign.accent
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
            .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous)
                    .stroke(AppDesign.border, lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var holdingsPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(title: "Largest positions")

            if holdings.isEmpty {
                ContentUnavailableView("Add your first entry", systemImage: "doc.badge.plus", description: Text("Your holdings stay in SwiftData on this device."))
            } else {
                ForEach(holdings.prefix(5)) { holding in
                    HoldingRow(holding: holding, latestPrice: prices.first { $0.ticker == holding.ticker }?.price)
                }
            }
        }
        .padding(16)
        .background(AppDesign.surface, in: RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous)
                .stroke(AppDesign.border, lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.03), radius: 2, y: 1)
    }

    @MainActor
    private func refreshQuotes() async {
        isRefreshing = true
        defer { isRefreshing = false }

        do {
            let requests = quoteRequests
            let quotes = try await quoteService.fetchQuotes(for: requests)

            let returnedTickers = Set(quotes.map(\.ticker))
            let missingTickers = requests
                .filter { !returnedTickers.contains($0.ticker) }
                .map { request in
                    if let isin = request.isin {
                        return "\(request.ticker) / \(isin)"
                    }

                    return request.ticker
                }
                .sorted()

            for quote in quotes {
                if let snapshot = prices.first(where: { $0.ticker == quote.ticker }) {
                    snapshot.price = quote.price
                    snapshot.fetchedAt = quote.fetchedAt
                } else {
                    modelContext.insert(PriceSnapshot(ticker: quote.ticker, price: quote.price, fetchedAt: quote.fetchedAt))
                }
            }
            try modelContext.save()

            if !missingTickers.isEmpty {
                showToast(
                    title: "Some prices were not fetched",
                    message: "No quote was returned for \(missingTickers.joined(separator: ", ")). Check the ticker or exchange suffix.",
                    systemImage: "exclamationmark.triangle.fill"
                )
            }
        } catch {
            showToast(
                title: "Could not refresh prices",
                message: error.localizedDescription,
                systemImage: "wifi.exclamationmark"
            )
        }
    }

    private var quoteRequests: [QuoteRequest] {
        var byTicker: [String: QuoteRequest] = [:]
        let currency = PortfolioCurrency(rawValue: selectedCurrencyCode) ?? .eur

        for holding in holdings {
            let request = QuoteRequest(ticker: holding.ticker, isin: holding.isin, currency: currency)
            guard !request.ticker.isEmpty else { continue }

            if byTicker[request.ticker]?.isin == nil || request.isin != nil {
                byTicker[request.ticker] = request
            }
        }

        return byTicker.values.sorted { $0.ticker < $1.ticker }
    }

    private func showToast(title: String, message: String, systemImage: String) {
        let toast = ToastMessage(title: title, message: message, systemImage: systemImage)

        withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
            self.toast = toast
        }

        Task {
            try? await Task.sleep(for: .seconds(5))
            guard self.toast == toast else { return }

            withAnimation(.easeOut(duration: 0.2)) {
                self.toast = nil
            }
        }
    }
}
