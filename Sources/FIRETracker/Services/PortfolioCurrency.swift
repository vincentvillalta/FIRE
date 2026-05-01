import Foundation

enum PortfolioCurrency: String, CaseIterable, Identifiable, Sendable {
    case usd = "USD"
    case eur = "EUR"
    case cad = "CAD"
    case gbp = "GBP"
    case chf = "CHF"
    case jpy = "JPY"
    case aud = "AUD"

    var id: String { rawValue }

    var name: String {
        switch self {
        case .usd: "US Dollar"
        case .eur: "Euro"
        case .cad: "Canadian Dollar"
        case .gbp: "British Pound"
        case .chf: "Swiss Franc"
        case .jpy: "Japanese Yen"
        case .aud: "Australian Dollar"
        }
    }

    var yahooSuffixes: [String] {
        switch self {
        case .usd:
            [""]
        case .eur:
            [".DE", ".AS", ".MI", ".PA", ".SW"]
        case .cad:
            [".TO", ".V"]
        case .gbp:
            [".L"]
        case .chf:
            [".SW"]
        case .jpy:
            [".T"]
        case .aud:
            [".AX"]
        }
    }

    static var selected: PortfolioCurrency {
        get {
            let code = UserDefaults.standard.string(forKey: UserDefaultsKey.portfolioCurrency) ?? PortfolioCurrency.eur.rawValue
            return PortfolioCurrency(rawValue: code) ?? .eur
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaultsKey.portfolioCurrency)
        }
    }
}

enum UserDefaultsKey {
    static let portfolioCurrency = "portfolioCurrency"
    static let hasCompletedWalkthrough = "hasCompletedWalkthrough"
}
