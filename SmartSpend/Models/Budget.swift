import Foundation

struct CategoryBudget: Identifiable, Codable, Equatable {
    let id: UUID
    let category: ExpenseCategory
    var amount: Double
    var isEnabled: Bool
    
    init(category: ExpenseCategory, amount: Double = 0.0, isEnabled: Bool = false) {
        self.id = UUID()
        self.category = category
        self.amount = amount
        self.isEnabled = isEnabled
    }
}

struct SpendingGoal: Identifiable, Codable {
    let id: UUID
    var title: String
    var targetAmount: Double
    var currentAmount: Double
    var deadline: Date
    var isCompleted: Bool
    var category: ExpenseCategory
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    init(title: String, targetAmount: Double, deadline: Date, category: ExpenseCategory = .other) {
        self.id = UUID()
        self.title = title
        self.targetAmount = targetAmount
        self.currentAmount = 0.0
        self.deadline = deadline
        self.isCompleted = false
        self.category = category
    }
}

struct SpendingTrend: Identifiable {
    let id: UUID
    let period: String
    let amount: Double
    let date: Date
    
    init(period: String, amount: Double, date: Date) {
        self.id = UUID()
        self.period = period
        self.amount = amount
        self.date = date
    }
}

struct CategoryInsight: Identifiable {
    let id: UUID
    let category: ExpenseCategory
    let currentMonth: Double
    let previousMonth: Double
    let percentageChange: Double
    let trend: TrendDirection
    
    enum TrendDirection {
        case up, down, stable
    }
    
    init(category: ExpenseCategory, currentMonth: Double, previousMonth: Double, percentageChange: Double, trend: TrendDirection) {
        self.id = UUID()
        self.category = category
        self.currentMonth = currentMonth
        self.previousMonth = previousMonth
        self.percentageChange = percentageChange
        self.trend = trend
    }
}
