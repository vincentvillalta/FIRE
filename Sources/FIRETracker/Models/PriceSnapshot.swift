import Foundation
import SwiftData

@Model
final class PriceSnapshot {
    @Attribute(.unique) var ticker: String
    var price: Decimal
    var fetchedAt: Date

    init(ticker: String, price: Decimal, fetchedAt: Date = .now) {
        self.ticker = ticker.uppercased()
        self.price = price
        self.fetchedAt = fetchedAt
    }
}
