import Foundation

struct Expense: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var amount: Double
    var category: ExpenseCategory
    var userCategoryId: UUID? // Link to UserCategory
    var date: Date
    var notionId: String?
    
    init(title: String, amount: Double, category: ExpenseCategory, userCategoryId: UUID? = nil, date: Date = Date(), notionId: String? = nil) {
        self.title = title
        self.amount = amount
        self.category = category
        self.userCategoryId = userCategoryId
        self.date = date
        self.notionId = notionId
    }
}
