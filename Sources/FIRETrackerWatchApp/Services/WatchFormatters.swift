import Foundation

extension Double {
    var watchCurrency: String {
        Self.currencyFormatter.string(from: NSNumber(value: self)) ?? "€0.00"
    }

    var watchPercent: String {
        Self.percentFormatter.string(from: NSNumber(value: self)) ?? "0.00%"
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    private static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
}

