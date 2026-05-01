import Foundation
import SwiftData

@Model
final class HoldingLot {
    @Attribute(.unique) var id: UUID
    var ticker: String
    var isin: String?
    var name: String
    var invested: Decimal
    var boughtAt: Decimal
    var shareCount: Decimal
    var purchaseDate: Date
    var importedAt: Date

    init(
        id: UUID = UUID(),
        ticker: String,
        isin: String? = nil,
        name: String,
        invested: Decimal,
        boughtAt: Decimal,
        shareCount: Decimal,
        purchaseDate: Date,
        importedAt: Date = .now
    ) {
        self.id = id
        self.ticker = ticker.uppercased()
        self.isin = isin?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased().nilIfEmpty
        self.name = name
        self.invested = invested
        self.boughtAt = boughtAt
        self.shareCount = shareCount
        self.purchaseDate = purchaseDate
        self.importedAt = importedAt
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
