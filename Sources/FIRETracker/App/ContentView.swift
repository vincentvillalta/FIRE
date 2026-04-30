import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var watchSync: WatchSnapshotSync

    @Query(sort: \HoldingLot.purchaseDate) private var holdings: [HoldingLot]
    @Query private var prices: [PriceSnapshot]
    @Query private var profiles: [FIREProfile]

    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Today", systemImage: "chart.line.uptrend.xyaxis") }

            HoldingsView()
                .tabItem { Label("Holdings", systemImage: "briefcase") }

            FIREPlanView()
                .tabItem { Label("Plan", systemImage: "flame") }

            AddEntryView()
                .tabItem { Label("Add", systemImage: "plus.circle") }

            SettingsView()
                .tabItem { Label("Privacy", systemImage: "lock.shield") }
        }
        .tint(.teal)
        .onAppear {
            watchSync.send(snapshot: watchSnapshot)
        }
        .onChange(of: watchSnapshot) { _, snapshot in
            watchSync.send(snapshot: snapshot)
        }
    }

    private var watchSnapshot: WatchPortfolioSnapshot {
        let metric = PortfolioCalculator.metrics(holdings: holdings, prices: prices)
        let profile = profiles.first ?? FIREProfile()
        let plan = FIRECalculator.plan(profile: profile, portfolioValue: metric.currentValue)
        return WatchPortfolioSnapshot(metric: metric, firePlan: plan)
    }
}
