import Foundation

struct QuoteRequest: Sendable, Hashable {
    let ticker: String
    let isin: String?
    let currency: PortfolioCurrency

    init(ticker: String, isin: String? = nil, currency: PortfolioCurrency = .selected) {
        self.ticker = ticker.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        self.isin = isin?.trimmingCharacters(in: .whitespacesAndNewlines).uppercased().nilIfEmpty
        self.currency = currency
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
