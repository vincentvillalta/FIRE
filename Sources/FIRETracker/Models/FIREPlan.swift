import Foundation

struct FIREPlan {
    let fireNumber: Decimal
    let currentValue: Decimal
    let monthlyInvestment: Decimal
    let targetMonthlyInvestment: Decimal
    let monthlyGap: Decimal
    let monthsToFire: Int?
    let fireDate: Date?
    let fireAge: Int?
    let investedSinceStart: Decimal
    let monthsSinceStart: Int
    let progress: Decimal

    var isOnTrack: Bool {
        monthlyGap <= 0
    }
}
