import Foundation

enum Language: String, CaseIterable, Codable {
    case english = "en"
    case russian = "ru"
    
    var name: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        }
    }
    
    var locale: Locale {
        return Locale(identifier: rawValue)
    }
    
    var englishName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Russian"
        }
    }
}

