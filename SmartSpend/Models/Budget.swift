import Foundation

struct CategoryBudget: Identifiable, Codable, Equatable {
    let id: UUID
    let categoryId: UUID
    var amount: Double
    var isEnabled: Bool
    
    init(categoryId: UUID, amount: Double = 0.0, isEnabled: Bool = false) {
        self.id = UUID()
        self.categoryId = categoryId
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
    var categoryId: UUID
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    init(title: String, targetAmount: Double, deadline: Date, categoryId: UUID) {
        self.id = UUID()
        self.title = title
        self.targetAmount = targetAmount
        self.currentAmount = 0.0
        self.deadline = deadline
        self.isCompleted = false
        self.categoryId = categoryId
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
    let categoryId: UUID
    let currentMonth: Double
    let previousMonth: Double
    let percentageChange: Double
    let trend: TrendDirection
    
    enum TrendDirection {
        case up, down, stable
    }
    
    init(categoryId: UUID, currentMonth: Double, previousMonth: Double, percentageChange: Double, trend: TrendDirection) {
        self.id = UUID()
        self.categoryId = categoryId
        self.currentMonth = currentMonth
        self.previousMonth = previousMonth
        self.percentageChange = percentageChange
        self.trend = trend
    }
}
