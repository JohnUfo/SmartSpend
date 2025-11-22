import Foundation

struct User: Codable {
    var currency: Currency
    var language: Language
    
    init(currency: Currency = .usd, language: Language = .english) {
        self.currency = currency
        self.language = language
    }
}
