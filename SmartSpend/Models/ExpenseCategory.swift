import SwiftUI

enum ExpenseCategory: String, CaseIterable, Codable {
    case food = "Food"
    case transportation = "Transportation"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case bills = "Bills"
    case healthcare = "Healthcare"
    case education = "Education"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transportation: return "car.fill"
        case .entertainment: return "theatermasks.fill"
        case .shopping: return "bag.fill"
        case .bills: return "receipt.fill"
        case .healthcare: return "heart.fill"
        case .education: return "graduationcap.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return Color(.systemOrange)
        case .transportation: return Color(.systemBlue)
        case .entertainment: return Color(.systemPurple)
        case .shopping: return Color(.systemPink)
        case .bills: return Color(.systemRed)
        case .healthcare: return Color(.systemGreen)
        case .education: return Color(.systemIndigo)
        case .other: return Color(.systemGray)
        }
    }
}
