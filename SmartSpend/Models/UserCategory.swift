import Foundation
import SwiftUI

struct UserCategory: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var iconSystemName: String
    var colorName: String
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, iconSystemName: String = "tag.fill", colorName: String = "systemBlue") {
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.iconSystemName = iconSystemName
        self.colorName = colorName
        self.createdAt = Date()
    }
    
    static func createDefault() -> UserCategory {
        return UserCategory(name: "General", iconSystemName: "cart.fill", colorName: "systemBlue")
    }
}

extension UserCategory {
    var color: Color {
        switch colorName {
        case "systemRed": return Color(.systemRed)
        case "systemOrange": return Color(.systemOrange)
        case "systemYellow": return Color(.systemYellow)
        case "systemGreen": return Color(.systemGreen)
        case "systemMint": return Color(.systemMint)
        case "systemTeal": return Color(.systemTeal)
        case "systemCyan": return Color(.systemCyan)
        case "systemBlue": return Color(.systemBlue)
        case "systemIndigo": return Color(.systemIndigo)
        case "systemPurple": return Color(.systemPurple)
        case "systemPink": return Color(.systemPink)
        case "systemBrown": return Color(.systemBrown)
        case "systemGray": return Color(.systemGray)
        default: return Color(.systemBlue)
        }
    }
    
    static let presetColors: [String] = [
        "systemRed", "systemOrange", "systemYellow", "systemGreen", "systemMint",
        "systemTeal", "systemCyan", "systemBlue", "systemIndigo", "systemPurple",
        "systemPink", "systemBrown", "systemGray"
    ]
}


