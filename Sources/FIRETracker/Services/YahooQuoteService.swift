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

    private let knownISINSymbols: [String: [PortfolioCurrency: [String]]] = [
        "IE00B5BMR087": [
            .eur: ["SXR8.DE", "CSP1.DE", "CSSPX.MI"],
            .usd: ["CSPX.L"],
            .gbp: ["CSPX.L"]
        ]
    ]

    func fetchQuotes(for requests: [QuoteRequest]) async throws -> [Quote] {
        var quotes: [Quote] = []

        for request in normalizedRequests(requests) {
            if let quote = try await fetchQuote(for: request) {
                quotes.append(quote)
            }
        }

        return quotes
    }

    private func fetchQuote(for request: QuoteRequest) async throws -> Quote? {
        for symbol in await yahooSymbols(for: request) {
            guard let url = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/\(symbol)") else {
                throw QuoteError.invalidURL
            }

            var urlRequest = URLRequest(url: url)
            urlRequest.setValue("FIRETracker/1.0", forHTTPHeaderField: "User-Agent")

            do {
                let (data, response) = try await URLSession.shared.data(for: urlRequest)
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    continue
                }

                if let price = price(from: data, expectedCurrency: request.currency) {
                    return Quote(ticker: request.ticker, price: price, fetchedAt: .now)
                }
            } catch {
                continue
            }
        }

        return nil
    }

    private func yahooSymbols(for request: QuoteRequest) async -> [String] {
        var symbols: [String] = []

        if let isin = request.isin {
            symbols.append(contentsOf: knownISINSymbols[isin]?[request.currency] ?? [])

            if let resolved = await resolveSymbol(forISIN: isin) {
                symbols.append(resolved)
            }
        }

        symbols.append(contentsOf: yahooSymbols(for: request.ticker, currency: request.currency))
        return symbols.uniqued()
    }

    private func resolveSymbol(forISIN isin: String) async -> String? {
        guard var components = URLComponents(string: "https://query1.finance.yahoo.com/v1/finance/search") else {
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: isin),
            URLQueryItem(name: "quotesCount", value: "10"),
            URLQueryItem(name: "newsCount", value: "0")
        ]

        guard let url = components.url else { return nil }

        do {
            var request = URLRequest(url: url)
            request.setValue("FIRETracker/1.0", forHTTPHeaderField: "User-Agent")

            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }

            return symbol(fromSearchData: data)
        } catch {
            return nil
        }
    }

    private func symbol(fromSearchData data: Data) -> String? {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let quotes = json["quotes"] as? [[String: Any]]
        else {
            return nil
        }

        return quotes
            .compactMap { $0["symbol"] as? String }
            .first { !$0.isEmpty }
    }

    private func price(from data: Data, expectedCurrency: PortfolioCurrency) -> Decimal? {
        guard
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let chart = json["chart"] as? [String: Any],
            let results = chart["result"] as? [[String: Any]],
            let meta = results.first?["meta"] as? [String: Any]
        else {
            return nil
        }

        let yahooCurrency = meta["currency"] as? String

        if let price = meta["regularMarketPrice"] as? Double, price > 0 {
            return normalizedPrice(price, yahooCurrency: yahooCurrency, expectedCurrency: expectedCurrency)
        }

        if let previousClose = meta["previousClose"] as? Double, previousClose > 0 {
            return normalizedPrice(previousClose, yahooCurrency: yahooCurrency, expectedCurrency: expectedCurrency)
        }

        return nil
    }

    private func normalizedPrice(_ price: Double, yahooCurrency: String?, expectedCurrency: PortfolioCurrency) -> Decimal? {
        guard let yahooCurrency else {
            return Decimal(price)
        }

        if yahooCurrency.uppercased() == expectedCurrency.rawValue {
            return Decimal(price)
        }

        if yahooCurrency == "GBp", expectedCurrency == .gbp {
            return Decimal(price / 100)
        }

        return nil
    }

    private func normalizedRequests(_ requests: [QuoteRequest]) -> [QuoteRequest] {
        Array(Set(requests))
            .filter { !$0.ticker.isEmpty }
            .sorted { $0.ticker < $1.ticker }
    }

    private func yahooSymbols(for ticker: String, currency: PortfolioCurrency) -> [String] {
        if ticker.contains(".") {
            return [ticker]
        }

        let preferred = currency.yahooSuffixes.map { "\(ticker)\($0)" }
        let fallback = [".DE", ".AS", ".MI", ".PA", ".SW", ".TO", ".V", ".L", ".T", ".AX", ""]
            .map { "\(ticker)\($0)" }
        return (preferred + fallback).uniqued()
    }
}

private extension Array where Element == String {
    func uniqued() -> [String] {
        var seen = Set<String>()
        return filter { seen.insert($0).inserted }
    }
}
