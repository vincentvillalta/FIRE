import Foundation

extension WatchPortfolioSnapshot {
    init(metric: PortfolioMetric, firePlan: FIREPlan, currencyCode: String = PortfolioCurrency.selected.rawValue, updatedAt: Date = .now) {
        today = WatchTodaySnapshot(
            invested: metric.invested.doubleValue,
            currentValue: metric.currentValue.doubleValue,
            gain: metric.gain.doubleValue,
            gainPercent: metric.gainPercent.doubleValue,
            annualizedReturn: metric.annualizedReturn?.doubleValue,
            missingPriceCount: metric.missingPriceCount
        )

        fire = WatchFIRESnapshot(
            progress: firePlan.progress.doubleValue,
            fireNumber: firePlan.fireNumber.doubleValue,
            monthlyInvestment: firePlan.monthlyInvestment.doubleValue,
            targetMonthlyInvestment: firePlan.targetMonthlyInvestment.doubleValue,
            monthlyGap: firePlan.monthlyGap.doubleValue,
            monthsToFire: firePlan.monthsToFire,
            fireAge: firePlan.fireAge,
            fireDate: firePlan.fireDate,
            investedSinceStart: firePlan.investedSinceStart.doubleValue
        )

        self.currencyCode = currencyCode
        self.updatedAt = updatedAt
    }
}
