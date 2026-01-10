import Foundation

struct Expense: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var amount: Double
    var categoryId: UUID
    var date: Date
    var notionId: String?
    
    init(title: String, amount: Double, categoryId: UUID, date: Date = Date(), notionId: String? = nil) {
        self.title = title
        self.amount = amount
        self.categoryId = categoryId
        self.date = date
        self.notionId = notionId
    }
}
