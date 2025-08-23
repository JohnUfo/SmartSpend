import Foundation

struct ArchivedExpense: Identifiable, Codable {
    let id: UUID
    let originalId: UUID
    let title: String
    let amount: Double
    let category: ExpenseCategory
    let date: Date
    let archivedDate: Date
    
    init(from expense: Expense) {
        self.id = UUID()
        self.originalId = expense.id
        self.title = expense.title
        self.amount = expense.amount
        self.category = expense.category
        self.date = expense.date
        self.archivedDate = Date()
    }
}
