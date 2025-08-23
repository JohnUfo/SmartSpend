import Foundation
import SwiftUI

class DataImporter: ObservableObject {
    static let shared = DataImporter()
    
    private init() {}
    
    enum ImportFormat: String, CaseIterable {
        case csv = "CSV"
        case json = "JSON"
        
        var fileExtension: String {
            switch self {
            case .csv:
                return "csv"
            case .json:
                return "json"
            }
        }
        
        var icon: String {
            switch self {
            case .csv:
                return "tablecells"
            case .json:
                return "doc.text"
            }
        }
    }
    
    enum ImportResult {
        case success(importedCount: Int, skippedCount: Int, errors: [String])
        case failure(error: String)
    }
    
    // MARK: - CSV Import
    
    func importFromCSV(fileURL: URL, dataManager: DataManager) -> ImportResult {
        // Start accessing the security-scoped resource
        guard fileURL.startAccessingSecurityScopedResource() else {
            print("❌ Failed to access security-scoped resource")
            return .failure(error: "Could not access the selected file")
        }
        
        defer {
            fileURL.stopAccessingSecurityScopedResource()
        }
        
        do {
            print("🔍 Starting CSV import from: \(fileURL.lastPathComponent)")
            
            // Try multiple encodings to handle different CSV formats
            let encodings: [String.Encoding] = [.utf8, .utf16, .ascii, .isoLatin1]
            var csvContent: String?
            
            for encoding in encodings {
                if let content = try? String(contentsOf: fileURL, encoding: encoding) {
                    csvContent = content
                    print("✅ Successfully read file with encoding: \(encoding)")
                    break
                }
            }
            
            guard let content = csvContent else {
                print("❌ Failed to read CSV file with any supported encoding")
                return .failure(error: "Could not read CSV file with any supported encoding")
            }
            
            // Clean up the content - remove BOM and normalize line endings
            let cleanedContent = content
                .replacingOccurrences(of: "\u{FEFF}", with: "") // Remove BOM
                .replacingOccurrences(of: "\r\n", with: "\n") // Normalize line endings
                .replacingOccurrences(of: "\r", with: "\n")
            
            let lines = cleanedContent.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            print("📊 Found \(lines.count) non-empty lines in CSV")
            
            guard lines.count > 1 else {
                print("❌ CSV file has insufficient data")
                return .failure(error: "CSV file is empty or has no data rows")
            }
            
            // Parse header to understand column structure
            let header = parseCSVRow(lines[0])
            print("📋 Parsed headers: \(header)")
            
            guard !header.isEmpty else {
                print("❌ Could not parse CSV header")
                return .failure(error: "Could not parse CSV header")
            }
            
            let dataRows = Array(lines.dropFirst())
            
            // Detect CSV format (Notion, custom, etc.)
            let format = detectCSVFormat(header: header)
            print("🔍 Detected format: \(format)")
            
            var importedCount = 0
            var skippedCount = 0
            var errors: [String] = []
            var expensesToAdd: [Expense] = []
            
            for (index, row) in dataRows.enumerated() {
                if row.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    continue
                }
                
                do {
                    let expense = try parseExpenseFromRow(parseCSVRow(row), header: header, format: format)
                    expensesToAdd.append(expense)
                    importedCount += 1
                } catch {
                    let errorMessage = "Row \(index + 2): \(error.localizedDescription)"
                    errors.append(errorMessage)
                    skippedCount += 1
                }
            }
            
            // Add all expenses on main thread
            DispatchQueue.main.async {
                for expense in expensesToAdd {
                    dataManager.addExpense(expense)
                }
            }
            
            print("✅ Import completed: \(importedCount) imported, \(skippedCount) skipped")
            
            // Show detailed error information
            if !errors.isEmpty {
                print("⚠️ Skipped rows details:")
                let errorCounts = Dictionary(grouping: errors, by: { $0 })
                    .mapValues { $0.count }
                    .sorted { $0.value > $1.value }
                
                for (error, count) in errorCounts.prefix(10) {
                    print("   \(count)x: \(error)")
                }
                
                if errorCounts.count > 10 {
                    print("   ... and \(errorCounts.count - 10) more error types")
                }
            }
            
            return .success(importedCount: importedCount, skippedCount: skippedCount, errors: errors)
            
        } catch {
            print("❌ Import failed: \(error)")
            return .failure(error: error.localizedDescription)
        }
    }
    
    // MARK: - Preview Import
    
    func previewCSVImport(fileURL: URL) -> (headers: [String], sampleRows: [[String]], totalRows: Int)? {
        // Start accessing the security-scoped resource
        guard fileURL.startAccessingSecurityScopedResource() else {
            print("❌ Failed to access security-scoped resource")
            return nil
        }
        
        defer {
            fileURL.stopAccessingSecurityScopedResource()
        }
        
        print("🔍 Starting preview for: \(fileURL.lastPathComponent)")
        
        // Try multiple encodings to handle different CSV formats
        let encodings: [String.Encoding] = [.utf8, .utf16, .ascii, .isoLatin1]
        var csvContent: String?
        
        for encoding in encodings {
            print("🔍 Trying encoding: \(encoding)")
            if let content = try? String(contentsOf: fileURL, encoding: encoding) {
                csvContent = content
                print("✅ Successfully read with encoding: \(encoding)")
                break
            } else {
                print("❌ Failed with encoding: \(encoding)")
            }
        }
        
        guard let content = csvContent else {
            print("❌ Could not read file with any encoding")
            return nil
        }
        
        print("📄 Raw content length: \(content.count) characters")
        
        // Clean up the content - remove BOM and normalize line endings
        let cleanedContent = content
            .replacingOccurrences(of: "\u{FEFF}", with: "") // Remove BOM
            .replacingOccurrences(of: "\r\n", with: "\n") // Normalize line endings
            .replacingOccurrences(of: "\r", with: "\n")
        
        print("🧹 Cleaned content length: \(cleanedContent.count) characters")
        
        let lines = cleanedContent.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        print("📊 Non-empty lines found: \(lines.count)")
        
        guard lines.count > 1 else {
            print("❌ CSV file has insufficient data")
            return nil
        }
        
        // Parse header
        let header = parseCSVRow(lines[0])
        print("📋 Parsed headers: \(header)")
        
        guard !header.isEmpty else {
            print("❌ Could not parse CSV header")
            return nil
        }
        
        let dataRows = Array(lines.dropFirst())
        print("📊 Data rows found: \(dataRows.count)")
        
        // Take first 5 rows as sample
        let sampleRows = Array(dataRows.prefix(5)).map { parseCSVRow($0) }
        
        return (headers: header, sampleRows: sampleRows, totalRows: dataRows.count)
    }
    
    // MARK: - Format Detection
    
    private enum CSVFormat {
        case notion
        case custom
        case smartSpend
    }
    
    private func detectCSVFormat(header: [String]) -> CSVFormat {
        let normalizedHeader = header.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Notion format detection - handle "Expense(name of the expense)" format
        if normalizedHeader.contains("expense") && normalizedHeader.contains("amount") && normalizedHeader.contains("category") && normalizedHeader.contains("date") {
            return .notion
        }
        
        // Alternative Notion format detection
        if normalizedHeader.contains("date") && normalizedHeader.contains("title") && normalizedHeader.contains("amount") {
            return .notion
        }
        
        // SmartSpend format detection
        if normalizedHeader.contains("date") && normalizedHeader.contains("title") && normalizedHeader.contains("amount") && normalizedHeader.contains("category") {
            return .smartSpend
        }
        
        return .custom
    }
    

    
    // MARK: - Helper Methods
    
    private func parseExpenseFromRow(_ columns: [String], header: [String], format: CSVFormat) throws -> Expense {
        switch format {
        case .notion:
            return try parseNotionRow(columns: columns, header: header)
        case .smartSpend:
            return try parseSmartSpendRow(columns: columns, header: header)
        case .custom:
            return try parseCustomRow(columns: columns, header: header)
        }
    }
    
    private func parseNotionRow(columns: [String], header: [String]) throws -> Expense {
        guard let expenseIndex = header.firstIndex(where: { $0.lowercased() == "expense" }),
              let amountIndex = header.firstIndex(where: { $0.lowercased() == "amount" }),
              let categoryIndex = header.firstIndex(where: { $0.lowercased() == "category" }),
              let dateIndex = header.firstIndex(where: { $0.lowercased() == "date" }) else {
            throw ImportError.missingColumns
        }
        
        let title = columns[expenseIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let amountString = columns[amountIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let categoryString = columns[categoryIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let dateString = columns[dateIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !title.isEmpty else {
            throw ImportError.invalidData("Missing title")
        }
        
        guard let amount = parseAmount(amountString) else {
            throw ImportError.invalidData("Invalid amount: \(amountString)")
        }
        
        guard let category = parseCategory(categoryString) else {
            throw ImportError.invalidData("Invalid category: \(categoryString)")
        }
        
        guard let date = parseDate(dateString) else {
            throw ImportError.invalidData("Invalid date: \(dateString)")
        }
        
        return Expense(title: title, amount: amount, category: category, date: date)
    }
    
    private func parseSmartSpendRow(columns: [String], header: [String]) throws -> Expense {
        guard let dateIndex = header.firstIndex(where: { $0.lowercased() == "date" }),
              let titleIndex = header.firstIndex(where: { $0.lowercased() == "title" }),
              let amountIndex = header.firstIndex(where: { $0.lowercased() == "amount" }),
              let categoryIndex = header.firstIndex(where: { $0.lowercased() == "category" }) else {
            throw ImportError.missingColumns
        }
        
        let title = columns[titleIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let amountString = columns[amountIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let categoryString = columns[categoryIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let dateString = columns[dateIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !title.isEmpty else {
            throw ImportError.invalidData("Missing title")
        }
        
        guard let amount = parseAmount(amountString) else {
            throw ImportError.invalidData("Invalid amount: \(amountString)")
        }
        
        guard let category = parseCategory(categoryString) else {
            throw ImportError.invalidData("Invalid category: \(categoryString)")
        }
        
        guard let date = parseDate(dateString) else {
            throw ImportError.invalidData("Invalid date: \(dateString)")
        }
        
        return Expense(title: title, amount: amount, category: category, date: date)
    }
    
    private func parseCustomRow(columns: [String], header: [String]) throws -> Expense {
        // Try to intelligently map columns
        var title = ""
        var amount: Double = 0
        var date = Date()
        var category: ExpenseCategory = .food
        
        for (index, columnName) in header.enumerated() {
            guard index < columns.count else { break }
            
            let value = columns[index].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Try to match column names
            if columnName.lowercased().contains("title") || columnName.lowercased().contains("name") || columnName.lowercased().contains("description") {
                title = value
            } else if columnName.lowercased().contains("amount") || columnName.lowercased().contains("price") || columnName.lowercased().contains("cost") {
                if let parsedAmount = parseAmount(value) {
                    amount = parsedAmount
                }
            } else if columnName.lowercased().contains("date") {
                if let parsedDate = parseDate(value) {
                    date = parsedDate
                }
            } else if columnName.lowercased().contains("category") || columnName.lowercased().contains("type") {
                if let parsedCategory = parseCategory(value) {
                    category = parsedCategory
                }
            }
        }
        
        guard !title.isEmpty else {
            throw ImportError.invalidData("Could not find title column")
        }
        
        guard amount > 0 else {
            throw ImportError.invalidData("Could not parse amount")
        }
        
        return Expense(title: title, amount: amount, category: category, date: date)
    }
    
    enum ImportError: Error, LocalizedError {
        case missingColumns
        case invalidData(String)
        
        var errorDescription: String? {
            switch self {
            case .missingColumns:
                return "Missing required columns in CSV file"
            case .invalidData(let message):
                return message
            }
        }
    }
    
    private func parseCSVRow(_ row: String) -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false
        var escapeNext = false
        
        for (index, char) in row.enumerated() {
            if escapeNext {
                currentColumn.append(char)
                escapeNext = false
                continue
            }
            
            if char == "\\" {
                escapeNext = true
                continue
            }
            
            if char == "\"" {
                if insideQuotes && index + 1 < row.count && row[row.index(row.startIndex, offsetBy: index + 1)] == "\"" {
                    // Handle escaped quotes: ""
                    currentColumn.append("\"")
                    // Skip the next quote
                    continue
                }
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                columns.append(currentColumn.trimmingCharacters(in: .whitespaces))
                currentColumn = ""
            } else {
                currentColumn.append(char)
            }
        }
        
        // Add the last column
        columns.append(currentColumn.trimmingCharacters(in: .whitespaces))
        
        // Clean up the columns - remove quotes and extra whitespace
        return columns.map { column in
            var cleaned = column.trimmingCharacters(in: .whitespaces)
            if cleaned.hasPrefix("\"") && cleaned.hasSuffix("\"") {
                cleaned = String(cleaned.dropFirst().dropLast())
            }
            return cleaned.trimmingCharacters(in: .whitespaces)
        }
    }
    
    private func parseAmount(_ value: String) -> Double? {
        // Remove currency symbols, commas, and spaces
        let cleaned = value.replacingOccurrences(of: "[^0-9.-]", with: "", options: .regularExpression)
        
        // Handle empty or invalid values
        guard !cleaned.isEmpty else { return nil }
        
        let amount = Double(cleaned)
        
        // Validate amount is positive
        guard let validAmount = amount, validAmount > 0 else { return nil }
        
        return validAmount
    }
    
    private func parseDate(_ value: String) -> Date? {
        let formatters: [DateFormatter] = [
            createDateFormatter("yyyy-MM-dd"),
            createDateFormatter("MM/dd/yyyy"),
            createDateFormatter("dd/MM/yyyy"),
            createDateFormatter("yyyy-MM-dd HH:mm:ss"),
            createDateFormatter("MM/dd/yyyy HH:mm:ss"),
            createDateFormatter("dd-MM-yyyy"),
            createDateFormatter("dd.MM.yyyy"),
            createDateFormatter("MM-dd-yyyy")
        ]
        
        for formatter in formatters {
            if let date = formatter.date(from: value) {
                return date
            }
        }
        
        // Try parsing with relative date strings
        let relativeFormatters: [DateFormatter] = [
            createDateFormatter("MMM dd, yyyy"),
            createDateFormatter("MMMM dd, yyyy"),
            createDateFormatter("dd MMM yyyy"),
            createDateFormatter("dd MMMM yyyy")
        ]
        
        for formatter in relativeFormatters {
            formatter.locale = Locale(identifier: "en_US")
            if let date = formatter.date(from: value) {
                return date
            }
        }
        
        return nil
    }
    
    private func createDateFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }
    
    private func parseCategory(_ value: String) -> ExpenseCategory? {
        let normalized = value.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Map common category names to our categories
        switch normalized {
        case "food", "restaurant", "dining", "groceries", "meal", "cafe":
            return .food
        case "transport", "transportation", "uber", "lyft", "gas", "fuel", "taxi", "bus", "metro", "subway":
            return .transportation
        case "shopping", "clothes", "fashion", "retail", "store", "market":
            return .shopping
        case "entertainment", "movie", "game", "fun", "cinema", "theater", "concert":
            return .entertainment
        case "health", "healthcare", "medical", "pharmacy", "doctor", "hospital":
            return .healthcare
        case "bills", "utilities", "electricity", "rent", "home", "house", "apartment":
            return .bills
        case "education", "school", "course", "book", "university", "college", "study":
            return .education
        case "other", "others", "misc", "miscellaneous", "general", "personal":
            return .other
        default:
            // Try exact match with our categories
            return ExpenseCategory.allCases.first { $0.rawValue.lowercased() == normalized }
        }
    }
    

}
