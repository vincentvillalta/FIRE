import Foundation

enum FIRECalculator {
    static func plan(profile: FIREProfile, portfolioValue: Decimal, now: Date = .now) -> FIREPlan {
        let fireNumber = profile.safeWithdrawalRate <= 0 ? 0 : profile.targetAnnualSpend / profile.safeWithdrawalRate
        let monthlyInvestment = max(profile.monthlyInvestment, 0)
        let monthlyReturn = pow(1 + profile.expectedAnnualReturn.doubleValue, 1.0 / 12.0) - 1
        let monthsToFire = monthsToReachTarget(
            currentValue: portfolioValue.doubleValue,
            monthlyInvestment: monthlyInvestment.doubleValue,
            monthlyReturn: monthlyReturn,
            target: fireNumber.doubleValue
        )

        let targetMonthly = requiredMonthlyInvestment(
            currentValue: portfolioValue.doubleValue,
            monthlyReturn: monthlyReturn,
            target: fireNumber.doubleValue,
            months: monthsToFire ?? 360
        )
        let monthlyGap = Decimal(targetMonthly) - monthlyInvestment
        let fireDate = monthsToFire.flatMap { Calendar.current.date(byAdding: .month, value: $0, to: now) }
        let fireAge = monthsToFire.map { profile.currentAge + ($0 / 12) }
        let monthsSinceStart = max(Calendar.current.dateComponents([.month], from: profile.planStartDate, to: now).month ?? 0, 0)
        let investedSinceStart = Decimal(monthsSinceStart) * monthlyInvestment
        let progress = fireNumber <= 0 ? 0 : min(portfolioValue / fireNumber, 1)

        return FIREPlan(
            fireNumber: fireNumber,
            currentValue: portfolioValue,
            monthlyInvestment: monthlyInvestment,
            targetMonthlyInvestment: Decimal(targetMonthly),
            monthlyGap: monthlyGap,
            monthsToFire: monthsToFire,
            fireDate: fireDate,
            fireAge: fireAge,
            investedSinceStart: investedSinceStart,
            monthsSinceStart: monthsSinceStart,
            progress: progress
        )
    }

    static func monthlyInvestment(from annualIncome: Decimal, investmentRate: Decimal) -> Decimal {
        max(annualIncome, 0) * max(investmentRate, 0) / 12
    }

    private static func monthsToReachTarget(
        currentValue: Double,
        monthlyInvestment: Double,
        monthlyReturn: Double,
        target: Double
    ) -> Int? {
        guard target > 0 else { return 0 }
        guard currentValue < target else { return 0 }
        guard monthlyInvestment > 0 || monthlyReturn > 0 else { return nil }

        var value = max(currentValue, 0)
        for month in 1...1_200 {
            value = value * (1 + monthlyReturn) + monthlyInvestment
            if value >= target {
                return month
            }
        }
        return nil
    }

    private static func requiredMonthlyInvestment(
        currentValue: Double,
        monthlyReturn: Double,
        target: Double,
        months: Int
    ) -> Double {
        guard months > 0, target > currentValue else { return 0 }

        if monthlyReturn == 0 {
            return max((target - currentValue) / Double(months), 0)
        }

        let growth = pow(1 + monthlyReturn, Double(months))
        let numerator = target - currentValue * growth
        let denominator = (growth - 1) / monthlyReturn
        return max(numerator / denominator, 0)
    }
}
