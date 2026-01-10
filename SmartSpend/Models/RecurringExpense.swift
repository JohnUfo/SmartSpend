import Foundation

enum RecurrenceType: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
    
    var icon: String {
        switch self {
        case .daily:
            return "calendar.day.timeline.left"
        case .weekly:
            return "calendar.badge.clock"
        case .biweekly:
            return "calendar.badge.clock"
        case .monthly:
            return "calendar"
        case .quarterly:
            return "calendar.badge.plus"
        case .yearly:
            return "calendar.badge.exclamationmark"
        }
    }
    
    func nextDate(from date: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: date) ?? date
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        case .biweekly:
            return calendar.date(byAdding: .weekOfYear, value: 2, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: date) ?? date
        case .yearly:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
    }
}

struct RecurringExpense: Identifiable, Codable {
    let id: UUID
    var title: String
    var amount: Double
    var category: ExpenseCategory
    var userCategoryId: UUID? // Added userCategoryId
    var recurrenceType: RecurrenceType
    var startDate: Date
    var endDate: Date?
    var isActive: Bool
    var lastProcessedDate: Date?
    var createdDate: Date
    
    init(title: String, amount: Double, category: ExpenseCategory, userCategoryId: UUID? = nil, recurrenceType: RecurrenceType, startDate: Date, endDate: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.category = category
        self.userCategoryId = userCategoryId
        self.recurrenceType = recurrenceType
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = true
        self.createdDate = Date()
    }
    
    var nextDueDate: Date {
        let lastDate = lastProcessedDate ?? startDate
        return recurrenceType.nextDate(from: lastDate)
    }
    
    var isOverdue: Bool {
        return nextDueDate < Date()
    }
    
    var isDue: Bool {
        let calendar = Calendar.current
        return calendar.isDate(nextDueDate, inSameDayAs: Date()) || isOverdue
    }
    
    var isExpired: Bool {
        guard let endDate = endDate else { return false }
        return Date() > endDate
    }
    
    func shouldCreateExpense(on date: Date = Date()) -> Bool {
        guard isActive && !isExpired else { return false }
        
        // Check if we've already processed this date
        if let lastProcessed = lastProcessedDate {
            let calendar = Calendar.current
            if calendar.isDate(lastProcessed, inSameDayAs: date) {
                return false
            }
        }
        
        // Check if it's time for the next occurrence
        return date >= nextDueDate
    }
    
    func createExpense() -> Expense {
        return Expense(
            title: title,
            amount: amount,
            category: category,
            userCategoryId: userCategoryId, // Pass userCategoryId
            date: Date()
        )
    }
}

// MARK: - Recurring Expense Notification
struct RecurringExpenseNotification: Identifiable {
    let id = UUID()
    let recurringExpense: RecurringExpense
    let type: NotificationType
    
    enum NotificationType {
        case due
        case overdue
        case upcoming // 1 day before
        
        var title: String {
            switch self {
            case .due:
                return "Recurring Expense Due"
            case .overdue:
                return "Overdue Recurring Expense"
            case .upcoming:
                return "Upcoming Recurring Expense"
            }
        }
        
        var icon: String {
            switch self {
            case .due:
                return "bell.fill"
            case .overdue:
                return "exclamationmark.triangle.fill"
            case .upcoming:
                return "clock.fill"
            }
        }
        
        var color: String {
            switch self {
            case .due:
                return "blue"
            case .overdue:
                return "red"
            case .upcoming:
                return "orange"
            }
        }
    }
    
    var message: String {
        switch type {
        case .due:
            return "\(recurringExpense.title) is due today"
        case .overdue:
            return "\(recurringExpense.title) is overdue"
        case .upcoming:
            return "\(recurringExpense.title) is due tomorrow"
        }
    }
}
