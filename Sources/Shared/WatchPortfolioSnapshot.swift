import Foundation

struct WatchPortfolioSnapshot: Codable, Equatable {
    static let applicationContextKey = "watchPortfolioSnapshot"

    var today: WatchTodaySnapshot
    var fire: WatchFIRESnapshot
    var currencyCode: String
    var updatedAt: Date

    static let empty = WatchPortfolioSnapshot(
        today: WatchTodaySnapshot(
            invested: 0,
            currentValue: 0,
            gain: 0,
            gainPercent: 0,
            annualizedReturn: nil,
            missingPriceCount: 0
        ),
        fire: WatchFIRESnapshot(
            progress: 0,
            fireNumber: 0,
            monthlyInvestment: 0,
            targetMonthlyInvestment: 0,
            monthlyGap: 0,
            monthsToFire: nil,
            fireAge: nil,
            fireDate: nil,
            investedSinceStart: 0
        ),
        currencyCode: "EUR",
        updatedAt: .distantPast
    )
}

struct WatchTodaySnapshot: Codable, Equatable {
    var invested: Double
    var currentValue: Double
    var gain: Double
    var gainPercent: Double
    var annualizedReturn: Double?
    var missingPriceCount: Int
}

struct WatchFIRESnapshot: Codable, Equatable {
    var progress: Double
    var fireNumber: Double
    var monthlyInvestment: Double
    var targetMonthlyInvestment: Double
    var monthlyGap: Double
    var monthsToFire: Int?
    var fireAge: Int?
    var fireDate: Date?
    var investedSinceStart: Double

    var isOnTrack: Bool {
        monthlyGap <= 0
    }
}
