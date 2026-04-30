import Foundation

extension Decimal {
    static func clean(_ value: String?) -> Decimal? {
        guard let value else { return nil }
        var cleaned = value
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: "£", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if cleaned.contains(","), cleaned.contains(".") {
            cleaned = cleaned.replacingOccurrences(of: ",", with: "")
        } else if cleaned.contains(",") {
            cleaned = cleaned.replacingOccurrences(of: ",", with: ".")
        }

        return Decimal(string: cleaned, locale: Locale(identifier: "en_US_POSIX"))
    }

    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }

    func rounded(scale: Int) -> Decimal {
        var value = self
        var result = Decimal()
        NSDecimalRound(&result, &value, scale, .plain)
        return result
    }
}

extension FormatStyle where Self == Decimal.FormatStyle.Currency {
    static var portfolioCurrency: Decimal.FormatStyle.Currency {
        .currency(code: "EUR")
            .precision(.fractionLength(2))
    }
}

extension FormatStyle where Self == Decimal.FormatStyle.Percent {
    static var portfolioPercent: Decimal.FormatStyle.Percent {
        .percent
            .precision(.fractionLength(2))
    }
}
