import Foundation

struct PriceCategoryCombination: Codable, Equatable {
    let price: Double
    let category: ExpenseCategory
    var frequency: Int
    
    init(price: Double, category: ExpenseCategory, frequency: Int = 1) {
        self.price = price
        self.category = category
        self.frequency = frequency
    }
}

struct CategoryFrequency: Codable, Equatable {
    let category: ExpenseCategory
    var frequency: Int
    var lastUsed: Date
    
    init(category: ExpenseCategory, frequency: Int = 1) {
        self.category = category
        self.frequency = frequency
        self.lastUsed = Date()
    }
}

struct LearnedPattern: Identifiable, Codable {
    let id: UUID
    let title: String
    var combinations: [PriceCategoryCombination]
    var categoryFrequencies: [CategoryFrequency]
    var lastUsed: Date
    let keywords: [String] // Extracted keywords for better matching
    
    init(title: String, price: Double, category: ExpenseCategory) {
        self.id = UUID()
        self.title = title
        self.combinations = [PriceCategoryCombination(price: price, category: category, frequency: 1)]
        self.categoryFrequencies = [CategoryFrequency(category: category, frequency: 1)]
        self.lastUsed = Date()
        self.keywords = Self.extractKeywords(from: title)
    }
    
    // Get the most frequently used price-category combination
    var mostCommonCombination: PriceCategoryCombination? {
        return combinations.max(by: { $0.frequency < $1.frequency })
    }
    
    // Get total frequency across all combinations
    var totalFrequency: Int {
        return combinations.reduce(0) { $0 + $1.frequency }
    }
    
    // Get the most used price
    var mostUsedPrice: Double {
        return mostCommonCombination?.price ?? 0.0
    }
    
    // Get the most used category
    var mostUsedCategory: ExpenseCategory {
        return categoryFrequencies.max(by: { $0.frequency < $1.frequency })?.category ?? .other
    }
    
    // Get category confidence score (0.0 to 1.0)
    var categoryConfidence: Double {
        guard !categoryFrequencies.isEmpty else { return 0.0 }
        let maxFreq = categoryFrequencies.map { $0.frequency }.max() ?? 1
        let totalFreq = categoryFrequencies.reduce(0) { $0 + $1.frequency }
        return Double(maxFreq) / Double(totalFreq)
    }
    
    // Get top 3 most likely categories
    var topCategories: [ExpenseCategory] {
        return categoryFrequencies
            .sorted { $0.frequency > $1.frequency }
            .prefix(3)
            .map { $0.category }
    }
    
    // Add or update a price-category combination
    mutating func addCombination(price: Double, category: ExpenseCategory) {
        // Update price-category combination
        if let index = combinations.firstIndex(where: { $0.price == price && $0.category == category }) {
            combinations[index].frequency += 1
        } else {
            combinations.append(PriceCategoryCombination(price: price, category: category, frequency: 1))
        }
        
        // Update category frequency
        if let index = categoryFrequencies.firstIndex(where: { $0.category == category }) {
            categoryFrequencies[index].frequency += 1
            categoryFrequencies[index].lastUsed = Date()
        } else {
            categoryFrequencies.append(CategoryFrequency(category: category, frequency: 1))
        }
        
        // Update last used date
        self.lastUsed = Date()
    }
    
    // Calculate similarity score with another title (0.0 to 1.0)
    func similarityScore(with otherTitle: String) -> Double {
        let otherKeywords = Self.extractKeywords(from: otherTitle)
        
        // Exact title match
        if title.lowercased() == otherTitle.lowercased() {
            return 1.0
        }
        
        // Keyword matching
        let commonKeywords = Set(keywords).intersection(Set(otherKeywords))
        let totalKeywords = Set(keywords).union(Set(otherKeywords))
        
        if totalKeywords.isEmpty {
            return 0.0
        }
        
        let keywordScore = Double(commonKeywords.count) / Double(totalKeywords.count)
        
        // Partial title matching
        let titleSimilarity = Self.calculateStringSimilarity(title.lowercased(), otherTitle.lowercased())
        
        // Weighted combination
        return (keywordScore * 0.7) + (titleSimilarity * 0.3)
    }
    
    // Extract meaningful keywords from title
    private static func extractKeywords(from title: String) -> [String] {
        let stopWords = Set(["the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "by", "from", "up", "down", "out", "off", "over", "under", "again", "further", "then", "once", "here", "there", "when", "where", "why", "how", "all", "any", "both", "each", "few", "more", "most", "other", "some", "such", "no", "nor", "not", "only", "own", "same", "so", "than", "too", "very", "can", "will", "just", "should", "now"])
        
        let words = title.lowercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .map { $0.trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty && !stopWords.contains($0) && $0.count > 2 }
        
        return Array(Set(words)) // Remove duplicates
    }
    
    // Calculate string similarity using Levenshtein distance
    private static func calculateStringSimilarity(_ str1: String, _ str2: String) -> Double {
        let distance = levenshteinDistance(str1, str2)
        let maxLength = max(str1.count, str2.count)
        return maxLength == 0 ? 1.0 : 1.0 - (Double(distance) / Double(maxLength))
    }
    
    // Levenshtein distance calculation
    private static func levenshteinDistance(_ str1: String, _ str2: String) -> Int {
        let empty = Array(repeating: 0, count: str2.count + 1)
        var last = Array(0...str2.count)
        
        for (i, char1) in str1.enumerated() {
            var current = [i + 1] + empty
            for (j, char2) in str2.enumerated() {
                current[j + 1] = char1 == char2 ? last[j] : min(last[j], last[j + 1], current[j]) + 1
            }
            last = current
        }
        return last[str2.count]
    }
}
