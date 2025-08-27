import Foundation

struct Expense: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var notionId: String?
    
    init(title: String, amount: Double, category: ExpenseCategory, date: Date = Date(), notionId: String? = nil) {
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.notionId = notionId
    }
}
