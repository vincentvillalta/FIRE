import Foundation
import SwiftData

@Model
final class LiquidationLot {
    @Attribute(.unique) var id: UUID
    var holdingID: UUID
    var ticker: String
    var name: String
    var soldShares: Decimal
    var soldAt: Decimal
    var proceeds: Decimal
    var costBasis: Decimal
    var saleDate: Date
    var recordedAt: Date

    init(
        id: UUID = UUID(),
        holdingID: UUID,
        ticker: String,
        name: String,
        soldShares: Decimal,
        soldAt: Decimal,
        proceeds: Decimal,
        costBasis: Decimal,
        saleDate: Date,
        recordedAt: Date = .now
    ) {
        self.id = id
        self.holdingID = holdingID
        self.ticker = ticker.uppercased()
        self.name = name
        self.soldShares = soldShares
        self.soldAt = soldAt
        self.proceeds = proceeds
        self.costBasis = costBasis
        self.saleDate = saleDate
        self.recordedAt = recordedAt
    }
}
