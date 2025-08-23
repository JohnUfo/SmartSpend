import Foundation

enum Currency: String, CaseIterable, Codable {
    case uzs = "UZS"
    case usd = "USD"
    
    var symbol: String {
        switch self {
        case .uzs: return "UZS"
        case .usd: return "USD"
        }
    }
    
    var locale: Locale {
        switch self {
        case .uzs: return Locale(identifier: "uz_UZ")
        case .usd: return Locale(identifier: "en_US")
        }
    }
    
    var name: String {
        switch self {
        case .uzs: return "Sum"
        case .usd: return "US Dollar"
        }
    }
}

struct User: Codable {
    var currency: Currency
    
    init(currency: Currency = .usd) {
        self.currency = currency
    }
}
