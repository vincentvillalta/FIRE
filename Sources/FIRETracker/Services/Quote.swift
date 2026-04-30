import Foundation

struct Quote: Sendable {
    let ticker: String
    let price: Decimal
    let fetchedAt: Date
}
