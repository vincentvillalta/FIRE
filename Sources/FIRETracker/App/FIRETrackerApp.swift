import SwiftData
import SwiftUI

@main
struct FIRETrackerApp: App {
    @StateObject private var watchSync = WatchSnapshotSync()

    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: HoldingLot.self, LiquidationLot.self, PriceSnapshot.self, FIREProfile.self)
        } catch {
            fatalError("Unable to initialize SwiftData: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(watchSync)
        }
        .modelContainer(modelContainer)
    }
}
