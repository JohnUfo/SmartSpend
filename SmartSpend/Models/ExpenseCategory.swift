import SwiftUI

enum ExpenseCategory: String, CaseIterable, Codable {
    case food = "Food"
    case transportation = "Transportation"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case health = "Health"
    case bills = "Bills"
    case education = "Education"
    case travel = "Travel"
    case other = "Other"
    case groceries = "Groceries"
    case dining = "Dining"
    case utilities = "Utilities"
    case rent = "Rent"
    case insurance = "Insurance"
    case clothing = "Clothing"
    case gifts = "Gifts"
    case fitness = "Fitness"
    case pets = "Pets"
    case subscriptions = "Subscriptions"
    case home = "Home"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .entertainment: return "tv.fill"
        case .shopping: return "bag.fill"
        case .health: return "cross.case.fill"
        case .bills: return "doc.text.fill"
        case .education: return "book.fill"
        case .travel: return "airplane"
        case .other: return "ellipsis.circle.fill"
        case .groceries: return "cart.fill"
        case .dining: return "fork.knife.circle.fill"
        case .utilities: return "bolt.fill"
        case .rent: return "house.fill"
        case .insurance: return "shield.fill"
        case .clothing: return "tshirt.fill"
        case .gifts: return "gift.fill"
        case .fitness: return "figure.run"
        case .pets: return "pawprint.fill"
        case .subscriptions: return "repeat.circle.fill"
        case .home: return "house.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return .orange
        case .transportation: return .blue
        case .entertainment: return .purple
        case .shopping: return .pink
        case .health: return .red
        case .bills: return .green
        case .education: return .indigo
        case .travel: return .cyan
        case .other: return .gray
        case .groceries: return .yellow
        case .dining: return .orange
        case .utilities: return .teal
        case .rent: return .brown
        case .insurance: return .mint
        case .clothing: return .pink
        case .gifts: return .red
        case .fitness: return .green
        case .pets: return .brown
        case .subscriptions: return .indigo
        case .home: return .blue
        }
    }
    
    var localizedName: String {
        return self.rawValue
    }
}
