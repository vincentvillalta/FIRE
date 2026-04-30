import Foundation

actor YahooQuoteService: QuoteService {
    enum QuoteError: LocalizedError {
        case invalidURL

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                "Could not build quote request."
            }
        }
    }

    func fetchQuotes(for tickers: [String]) async throws -> [Quote] {
        var quotes: [Quote] = []

        for ticker in normalizedTickers(tickers) {
            if let quote = try await fetchQuote(for: ticker) {
                quotes.append(quote)
            }
        }

        return quotes
    }

    private func fetchQuote(for ticker: String) async throws -> Quote? {
        for symbol in yahooSymbols(for: ticker) {
            guard let url = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/\(symbol)") else {
                throw QuoteError.invalidURL
            }

            var request = URLRequest(url: url)
            request.setValue("FIRETracker/1.0", forHTTPHeaderField: "User-Agent")

            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    continue
                }

                if let price = price(from: data) {
                    return Quote(ticker: ticker, price: price, fetchedAt: .now)
                }
            } catch {
                continue
            }
        }

        return nil
    }

    private func price(from data: Data) -> Decimal? {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let chart = json["chart"] as? [String: Any],
            let results = chart["result"] as? [[String: Any]],
            let meta = results.first?["meta"] as? [String: Any]
        else {
            return nil
        }

        if let price = meta["regularMarketPrice"] as? Double, price > 0 {
            return Decimal(price)
        }

        if let previousClose = meta["previousClose"] as? Double, previousClose > 0 {
            return Decimal(previousClose)
        }

        return nil
    }

    private func normalizedTickers(_ tickers: [String]) -> [String] {
        Array(Set(tickers.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }))
            .filter { !$0.isEmpty }
            .sorted()
    }

    private func yahooSymbols(for ticker: String) -> [String] {
        if ticker.contains(".") {
            return [ticker]
        }

        return [
            "\(ticker).DE",
            "\(ticker).AS",
            "\(ticker).MI",
            "\(ticker).PA",
            "\(ticker).SW",
            ticker
        ]
    }
}
