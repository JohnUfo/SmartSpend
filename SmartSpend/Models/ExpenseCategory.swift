import SwiftUI

enum ExpenseCategory: String, CaseIterable, Codable {
    case other = "Other"
    
    var icon: String {
        switch self {
        case .other: return "tag.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .other: return .gray
        }
    }
    
    var localizedName: String {
        return self.rawValue
    }
}
