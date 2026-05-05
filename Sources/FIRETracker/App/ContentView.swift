import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var watchSync: WatchSnapshotSync

    @AppStorage(UserDefaultsKey.portfolioCurrency) private var selectedCurrencyCode = PortfolioCurrency.selected.rawValue
    @AppStorage(UserDefaultsKey.hasCompletedWalkthrough) private var hasCompletedWalkthrough = false
    @State private var selectedTab = MainTab.today

    @Query(sort: \HoldingLot.purchaseDate) private var holdings: [HoldingLot]
    @Query private var liquidations: [LiquidationLot]
    @Query private var prices: [PriceSnapshot]
    @Query private var profiles: [FIREProfile]

    var body: some View {
        Group {
            if hasCompletedWalkthrough {
                mainTabs
            } else {
                WalkthroughView { destination in
                    selectedTab = destination
                    hasCompletedWalkthrough = true
                }
            }
        }
    }

    private var mainTabs: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Today", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(MainTab.today)

            HoldingsView()
                .tabItem { Label("Holdings", systemImage: "briefcase") }
                .tag(MainTab.holdings)

            FIREPlanView()
                .tabItem { Label("Plan", systemImage: "flame") }
                .tag(MainTab.plan)

            AddEntryView()
                .tabItem { Label("Add", systemImage: "plus.circle") }
                .tag(MainTab.add)

            SettingsView()
                .tabItem { Label("Privacy", systemImage: "lock.shield") }
                .tag(MainTab.settings)
        }
        .tint(AppDesign.accent)
        .id(selectedCurrencyCode)
        .onAppear {
            watchSync.send(snapshot: watchSnapshot)
        }
        .onChange(of: watchSnapshot) { _, snapshot in
            watchSync.send(snapshot: snapshot)
        }
    }

    private var watchSnapshot: WatchPortfolioSnapshot {
        let metric = PortfolioCalculator.metrics(holdings: holdings, prices: prices, liquidations: liquidations)
        let profile = profiles.first ?? FIREProfile()
        let plan = FIRECalculator.plan(profile: profile, portfolioValue: metric.currentValue)
        return WatchPortfolioSnapshot(metric: metric, firePlan: plan, currencyCode: selectedCurrencyCode, updatedAt: watchSnapshotUpdatedAt)
    }

    private var watchSnapshotUpdatedAt: Date {
        let dates = holdings.map(\.importedAt) + liquidations.map(\.recordedAt) + prices.map(\.fetchedAt) + profiles.map(\.updatedAt)
        return dates.max() ?? .distantPast
    }
}

enum MainTab: Hashable {
    case today
    case holdings
    case plan
    case add
    case settings
}
