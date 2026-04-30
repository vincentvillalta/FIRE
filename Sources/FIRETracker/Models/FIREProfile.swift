import Foundation
import SwiftData

@Model
final class FIREProfile {
    @Attribute(.unique) var id: UUID
    var currentAge: Int
    var annualIncome: Decimal
    var monthlyInvestment: Decimal
    var targetAnnualSpend: Decimal
    var investmentRate: Decimal
    var expectedAnnualReturn: Decimal
    var safeWithdrawalRate: Decimal
    var planStartDate: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        currentAge: Int = 35,
        annualIncome: Decimal = 75_000,
        monthlyInvestment: Decimal = 1_250,
        targetAnnualSpend: Decimal = 36_000,
        investmentRate: Decimal = 0.20,
        expectedAnnualReturn: Decimal = 0.07,
        safeWithdrawalRate: Decimal = 0.04,
        planStartDate: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.currentAge = currentAge
        self.annualIncome = annualIncome
        self.monthlyInvestment = monthlyInvestment
        self.targetAnnualSpend = targetAnnualSpend
        self.investmentRate = investmentRate
        self.expectedAnnualReturn = expectedAnnualReturn
        self.safeWithdrawalRate = safeWithdrawalRate
        self.planStartDate = planStartDate
        self.updatedAt = updatedAt
    }
}
