import Foundation

struct MonthlySalary: Identifiable, Codable {
    let id: UUID
    let year: Int
    let month: Int
    let amount: Double
    let currency: Currency
    let dateSet: Date
    
    init(year: Int, month: Int, amount: Double, currency: Currency) {
        self.id = UUID()
        self.year = year
        self.month = month
        self.amount = amount
        self.currency = currency
        self.dateSet = Date()
    }
    
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
