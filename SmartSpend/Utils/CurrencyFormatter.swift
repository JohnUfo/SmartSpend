import Foundation

struct CurrencyFormatter {
    static func format(_ amount: Double, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.locale = currency.locale
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        if let formatted = formatter.string(from: NSNumber(value: amount)) {
            return formatted
        }
        
        // Fallback formatting
        let fallbackFormatter = NumberFormatter()
        fallbackFormatter.numberStyle = .decimal
        fallbackFormatter.minimumFractionDigits = 2
        fallbackFormatter.maximumFractionDigits = 2
        fallbackFormatter.groupingSeparator = ","
        fallbackFormatter.decimalSeparator = "."
        
        let formattedAmount = fallbackFormatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(formattedAmount) \(currency.symbol)"
    }
    
    static func formatCompact(_ amount: Double, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.rawValue
        formatter.locale = currency.locale
        formatter.maximumFractionDigits = 0
        
        if let formatted = formatter.string(from: NSNumber(value: amount)) {
            return formatted
        }
        
        // Fallback formatting
        let fallbackFormatter = NumberFormatter()
        fallbackFormatter.numberStyle = .decimal
        fallbackFormatter.maximumFractionDigits = 0
        fallbackFormatter.groupingSeparator = ","
        fallbackFormatter.decimalSeparator = "."
        
        let formattedAmount = fallbackFormatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
        return "\(formattedAmount) \(currency.symbol)"
    }
    
    static func formatPercentage(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value * 100))%"
    }
    
    static func formatWithSymbol(_ amount: Double, currency: Currency) -> String {
        return format(amount, currency: currency)
    }
}
