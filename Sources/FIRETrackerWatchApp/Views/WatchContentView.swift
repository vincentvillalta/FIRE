import SwiftUI

struct WatchContentView: View {
    @EnvironmentObject private var store: WatchSnapshotStore

    var body: some View {
        TabView {
            WatchTodayView(snapshot: store.snapshot.today, updatedAt: store.snapshot.updatedAt)
            WatchFIREView(snapshot: store.snapshot.fire, updatedAt: store.snapshot.updatedAt)
        }
        .tabViewStyle(.page)
        .task {
            store.requestLatestSnapshot()
        }
    }
}

