import Foundation
import SwiftData

@Model
final class HoldingLot {
    @Attribute(.unique) var id: UUID
    var ticker: String
    var name: String
    var invested: Decimal
    var boughtAt: Decimal
    var shareCount: Decimal
    var purchaseDate: Date
    var importedAt: Date

    init(
        id: UUID = UUID(),
        ticker: String,
        name: String,
        invested: Decimal,
        boughtAt: Decimal,
        shareCount: Decimal,
        purchaseDate: Date,
        importedAt: Date = .now
    ) {
        self.id = id
        self.ticker = ticker.uppercased()
        self.name = name
        self.invested = invested
        self.boughtAt = boughtAt
        self.shareCount = shareCount
        self.purchaseDate = purchaseDate
        self.importedAt = importedAt
    }
}
