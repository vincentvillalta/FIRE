import Foundation

protocol QuoteService: Sendable {
    func fetchQuotes(for tickers: [String]) async throws -> [Quote]
}
