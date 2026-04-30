import Foundation
import WatchConnectivity

@MainActor
final class WatchSnapshotSync: NSObject, ObservableObject {
    @Published private(set) var lastSyncedAt: Date?

    private var latestSnapshot: WatchPortfolioSnapshot?
    private let session: WCSession?

    override init() {
        if WCSession.isSupported() {
            session = WCSession.default
        } else {
            session = nil
        }

        super.init()

        session?.delegate = self
        session?.activate()
    }

    func send(snapshot: WatchPortfolioSnapshot) {
        latestSnapshot = snapshot

        guard let session, session.activationState == .activated else { return }
        guard let data = try? JSONEncoder().encode(snapshot) else { return }

        do {
            try session.updateApplicationContext([WatchPortfolioSnapshot.applicationContextKey: data])
            lastSyncedAt = .now
        } catch {
            // The next app activation or data change will attempt the sync again.
        }
    }
}

extension WatchSnapshotSync: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        Task { @MainActor in
            guard
                message["request"] as? String == "snapshot",
                let latestSnapshot,
                let data = try? JSONEncoder().encode(latestSnapshot)
            else {
                replyHandler([:])
                return
            }

            replyHandler([WatchPortfolioSnapshot.applicationContextKey: data])
        }
    }
}

