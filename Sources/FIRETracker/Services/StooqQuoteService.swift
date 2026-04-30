import Foundation

actor StooqQuoteService: QuoteService {
    enum QuoteError: LocalizedError {
        case invalidURL
        case networkFailed

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                "Could not build quote request."
            case .networkFailed:
                "Quote service did not return current prices."
            }
        }
    }

    func fetchQuotes(for tickers: [String]) async throws -> [Quote] {
        let requestedTickers = tickers
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }
            .filter { !$0.isEmpty }
        let requestedSymbols = requestedTickers.flatMap { ticker in
            stooqSymbols(for: ticker)
        }
        let symbolMap = Dictionary(uniqueKeysWithValues: requestedTickers.flatMap { ticker in
            stooqSymbols(for: ticker).map { ($0, ticker) }
        })
        let symbols = requestedSymbols.joined(separator: ",")

        guard !symbols.isEmpty else { return [] }

        var components = URLComponents(string: "https://stooq.com/q/l/")
        components?.queryItems = [
            URLQueryItem(name: "s", value: symbols),
            URLQueryItem(name: "f", value: "sd2t2c"),
            URLQueryItem(name: "h", value: ""),
            URLQueryItem(name: "e", value: "csv")
        ]

        guard let url = components?.url else { throw QuoteError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw QuoteError.networkFailed }

        let rows = String(decoding: data, as: UTF8.self)
            .split(separator: "\n")
            .map { $0.split(separator: ",", omittingEmptySubsequences: false).map(String.init) }

        var quotesByTicker: [String: Quote] = [:]

        for row in rows {
            guard row.count >= 4 else { continue }
            let rawSymbol = row[0].uppercased()
            guard let price = Decimal.clean(row[3]), price > 0 else { continue }
            guard let requestedTicker = symbolMap[rawSymbol.lowercased()] else { continue }
            guard quotesByTicker[requestedTicker] == nil else { continue }
            quotesByTicker[requestedTicker] = Quote(ticker: requestedTicker, price: price, fetchedAt: .now)
        }

        return requestedTickers.compactMap { quotesByTicker[$0] }
    }

    private func stooqSymbols(for ticker: String) -> [String] {
        let normalized = ticker.lowercased()
        if normalized.contains(".") {
            return [normalized]
        }

        return [
            "\(normalized).de",
            "\(normalized).nl",
            "\(normalized).it",
            "\(normalized).mi",
            "\(normalized).pa",
            "\(normalized).us"
        ]
    }
}
