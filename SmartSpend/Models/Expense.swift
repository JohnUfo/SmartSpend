import Foundation

struct Expense: Identifiable, Codable {
    var id = UUID()
    let title: String
    let amount: Double
    let category: ExpenseCategory
    let date: Date
    
    init(title: String, amount: Double, category: ExpenseCategory, date: Date = Date()) {
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
    }
}
