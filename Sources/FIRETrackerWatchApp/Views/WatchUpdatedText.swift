import SwiftUI

struct WatchUpdatedText: View {
    let date: Date

    var body: some View {
        if date == .distantPast {
            Text("Open iPhone app to sync")
                .font(.caption2)
                .foregroundStyle(.secondary)
        } else {
            Text("Updated \(date, format: .dateTime.hour().minute())")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

