import Foundation

struct CurrencyFormatter {
    static func format(_ amount: Double, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        
        let formattedAmount = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(formattedAmount) \(currency.symbol)"
    }
    
    static func formatCompact(_ amount: Double, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        
        let formattedAmount = formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
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
