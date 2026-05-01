import Foundation

protocol QuoteService: Sendable {
    func fetchQuotes(for requests: [QuoteRequest]) async throws -> [Quote]
}
