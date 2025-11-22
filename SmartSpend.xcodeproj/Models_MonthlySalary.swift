import Foundation

// MARK: - Monthly Salary Model
/// Represents a user's monthly salary for budget tracking
struct MonthlySalary: Identifiable, Codable {
    let id: UUID
    var year: Int
    var month: Int
    var amount: Double
    var currency: Currency
    
    init(id: UUID = UUID(), year: Int, month: Int, amount: Double, currency: Currency) {
        self.id = id
        self.year = year
        self.month = month
        self.amount = amount
        self.currency = currency
    }
    
    /// Returns a formatted date string for the salary month
    var monthYearString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        if let date = Calendar.current.date(from: components) {
            return dateFormatter.string(from: date)
        }
        return "\(month)/\(year)"
    }
}
