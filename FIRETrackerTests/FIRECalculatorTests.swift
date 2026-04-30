import XCTest
@testable import FIRETracker

final class FIRECalculatorTests: XCTestCase {
    func testCalculatesMonthlyInvestmentFromIncomeRate() {
        let monthly = FIRECalculator.monthlyInvestment(from: 120_000, investmentRate: 0.30)

        XCTAssertEqual(monthly, 3_000)
    }

    func testPlanReturnsFireDateWhenContributing() {
        let profile = FIREProfile(
            currentAge: 35,
            annualIncome: 100_000,
            monthlyInvestment: 2_000,
            targetAnnualSpend: 40_000,
            investmentRate: 0.24,
            expectedAnnualReturn: 0.07,
            safeWithdrawalRate: 0.04,
            planStartDate: Date(timeIntervalSince1970: 0)
        )

        let plan = FIRECalculator.plan(
            profile: profile,
            portfolioValue: 100_000,
            now: Date(timeIntervalSince1970: 1_700_000_000)
        )

        XCTAssertEqual(plan.fireNumber, 1_000_000)
        XCTAssertNotNil(plan.monthsToFire)
        XCTAssertNotNil(plan.fireDate)
        XCTAssertGreaterThan(plan.fireAge ?? 0, 35)
    }
}
