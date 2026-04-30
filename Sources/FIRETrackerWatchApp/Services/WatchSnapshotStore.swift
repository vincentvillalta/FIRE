import Foundation
import WatchConnectivity

@MainActor
final class WatchSnapshotStore: NSObject, ObservableObject {
    @Published private(set) var snapshot: WatchPortfolioSnapshot

    private let defaultsKey = "latestWatchPortfolioSnapshot"
    private let session: WCSession?

    override init() {
        snapshot = Self.loadSnapshot(defaultsKey: defaultsKey)

        if WCSession.isSupported() {
            session = WCSession.default
        } else {
            session = nil
        }

        super.init()

        session?.delegate = self
        session?.activate()
    }

    func requestLatestSnapshot() {
        guard let session, session.isReachable else { return }

        session.sendMessage(["request": "snapshot"], replyHandler: { [weak self] reply in
            guard let data = reply[WatchPortfolioSnapshot.applicationContextKey] as? Data else { return }
            Task { @MainActor in
                self?.apply(data: data)
            }
        }, errorHandler: nil)
    }

    private func apply(data: Data) {
        guard let snapshot = try? JSONDecoder().decode(WatchPortfolioSnapshot.self, from: data) else { return }
        self.snapshot = snapshot
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    private static func loadSnapshot(defaultsKey: String) -> WatchPortfolioSnapshot {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let snapshot = try? JSONDecoder().decode(WatchPortfolioSnapshot.self, from: data)
        else {
            return .empty
        }

        return snapshot
    }
}

extension WatchSnapshotStore: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let data = applicationContext[WatchPortfolioSnapshot.applicationContextKey] as? Data else { return }

        Task { @MainActor in
            self.apply(data: data)
        }
    }
}

