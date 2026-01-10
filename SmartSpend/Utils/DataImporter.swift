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
        
        var localizedName: String {
            switch self {
            case .csv:
                return "CSV"
            case .json:
                return "JSON"
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
            return .failure(error: "Failed to access file")
        }
        
        defer {
            fileURL.stopAccessingSecurityScopedResource()
        }
        
        do {
            // Try multiple encodings to handle different CSV formats
            let encodings: [String.Encoding] = [.utf8, .utf16, .ascii, .isoLatin1]
            var csvContent: String?
            
            for encoding in encodings {
                if let content = try? String(contentsOf: fileURL, encoding: encoding) {
                    csvContent = content
                    break
                }
            }
            
            guard let content = csvContent else {
                return .failure(error: "Failed to read file - unsupported encoding")
            }
            
            // Clean up the content - remove BOM and normalize line endings
            let cleanedContent = content
                .replacingOccurrences(of: "\u{FEFF}", with: "") // Remove BOM
                .replacingOccurrences(of: "\r\n", with: "\n") // Normalize line endings
                .replacingOccurrences(of: "\r", with: "\n")
            
            let lines = cleanedContent.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            guard lines.count > 1 else {
                return .failure(error: "CSV file is empty or has no data rows")
            }
            
            // Detect separator (comma or semicolon)
            let headerLine = lines[0]
            // Heuristic: If there are semicolons but no commas, assume semicolon separator
            let separator: Character = headerLine.contains(";") && !headerLine.contains(",") ? ";" : ","
            print("📝 Detected Separator: '\(separator)'")
            
            // Parse header to understand column structure
            let header = parseCSVRow(headerLine, separator: separator)
            print("📝 CSV Header: \(header)")
            
            guard !header.isEmpty else {
                return .failure(error: "Invalid CSV header")
            }
            
            let dataRows = Array(lines.dropFirst())
            
            // Detect CSV format (SmartSpend or custom)
            let format = detectCSVFormat(header: header)
            print("📝 Detected Format: \(format)")
            
            var importedCount = 0
            var skippedCount = 0
            var errors: [String] = []
            var expensesToAdd: [Expense] = []
            var foundCategories: Set<String> = []
            
            // First pass: collect all categories from the CSV
            print("🔄 First Pass: Collecting categories...")
            for row in dataRows {
                if row.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    continue
                }
                
                let parsedColumns = parseCSVRow(row, separator: separator)
                if let categoryString = extractCategoryString(parsedColumns, header: header, format: format) {
                    let normalized = categoryString.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Safety check: Don't treat dates as categories
                    // This prevents the error where a date column is misidentified as a category
                    if !normalized.isEmpty && parseDate(normalized) == nil {
                        foundCategories.insert(normalized)
                    }
                }
            }
            print("📝 Found \(foundCategories.count) unique categories: \(foundCategories)")
            
            // Sync with DataManager to create categories and get IDs
            // We need a map of category name -> UserCategory ID
            var categoryMap: [String: UUID] = [:]
            let semaphore = DispatchSemaphore(value: 0)
            
            DispatchQueue.main.async {
                print("🔄 Syncing categories with DataManager...")
                for categoryName in foundCategories {
                    let normalized = categoryName.lowercased()
                    
                    // Check if it matches an existing built-in ExpenseCategory
                    let matchesExpenseCategory = ExpenseCategory.allCases.contains { $0.rawValue.lowercased() == normalized }
                    
                    if !matchesExpenseCategory {
                        // Check if UserCategory already exists
                        if let existingCategory = dataManager.userCategories.first(where: { $0.name.lowercased() == normalized }) {
                            categoryMap[normalized] = existingCategory.id
                            print("   Mapped '\(categoryName)' to existing user category")
                        } else {
                            // Create new UserCategory
                            let newUserCategory = UserCategory(name: categoryName)
                            dataManager.addUserCategory(newUserCategory)
                            categoryMap[normalized] = newUserCategory.id
                            print("   Created new user category for '\(categoryName)'")
                        }
                    } else {
                        // It matches a built-in category, so we don't need a UserCategory ID
                        // but we rely on ExpenseCategory enum
                    }
                }
                semaphore.signal()
            }
            
            semaphore.wait()
            
            // Second pass: parse and create expenses
            print("🔄 Second Pass: Parsing expenses...")
            for (index, row) in dataRows.enumerated() {
                if row.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    continue
                }
                
                do {
                    let parsedColumns = parseCSVRow(row, separator: separator)
                    let expense = try parseExpenseFromRow(parsedColumns, header: header, format: format, categoryMap: categoryMap)
                    expensesToAdd.append(expense)
                    importedCount += 1
                } catch {
                    let parsedColumns = parseCSVRow(row, separator: separator)
                    let rowPreview = parsedColumns.prefix(3).joined(separator: ", ")
                    let errorMessage = "Row \(index + 2) [\(rowPreview)...]: \(error.localizedDescription)"
                    errors.append(errorMessage)
                    skippedCount += 1
                    
                    // Only print first 5 errors for debugging
                    if skippedCount <= 5 {
                        print("❌ Import Error on row \(index + 2): \(error.localizedDescription)")
                    }
                }
            }
            
            // Add all expenses on main thread
            let group = DispatchGroup()
            group.enter()
            
            DispatchQueue.main.async {
                print("🔄 Adding \(expensesToAdd.count) expenses to DataManager...")
                // Add expenses in batches to improve performance
                let chunkSize = 100
                for chunkStart in stride(from: 0, to: expensesToAdd.count, by: chunkSize) {
                    let chunkEnd = min(chunkStart + chunkSize, expensesToAdd.count)
                    let chunk = Array(expensesToAdd[chunkStart..<chunkEnd])
                    
                    for expense in chunk {
                        dataManager.addExpense(expense)
                    }
                    
                    // Allow UI to update between chunks
                    if chunkEnd < expensesToAdd.count {
                        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
                    }
                }
                
                group.leave()
            }
            
            // Wait for all async work to complete
            group.wait()
            
            print("✅ Import completed: \(importedCount) imported, \(skippedCount) skipped")
            
            if skippedCount > 5 {
                print("   (Showing only first 5 errors in console)")
            }
            
            return .success(importedCount: importedCount, skippedCount: skippedCount, errors: errors)
        }
    }
    
    // MARK: - Preview Import
    
    func previewCSVImport(fileURL: URL) -> (headers: [String], sampleRows: [[String]], totalRows: Int)? {
        // Start accessing the security-scoped resource
        guard fileURL.startAccessingSecurityScopedResource() else {
            return nil
        }
        
        defer {
            fileURL.stopAccessingSecurityScopedResource()
        }
        
        // Try multiple encodings to handle different CSV formats
        let encodings: [String.Encoding] = [.utf8, .utf16, .ascii, .isoLatin1]
        var csvContent: String?
        
        for encoding in encodings {
            if let content = try? String(contentsOf: fileURL, encoding: encoding) {
                csvContent = content
                break
            }
        }
        
        guard let content = csvContent else {
            return nil
        }
        
        // Clean up the content - remove BOM and normalize line endings
        let cleanedContent = content
            .replacingOccurrences(of: "\u{FEFF}", with: "") // Remove BOM
            .replacingOccurrences(of: "\r\n", with: "\n") // Normalize line endings
            .replacingOccurrences(of: "\r", with: "\n")
        
        let lines = cleanedContent.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard lines.count > 1 else {
            return nil
        }
        
        // Detect separator (comma or semicolon)
        let headerLine = lines[0]
        let separator: Character = headerLine.contains(";") && !headerLine.contains(",") ? ";" : ","
        
        // Parse header
        let header = parseCSVRow(headerLine, separator: separator)
        
        guard !header.isEmpty else {
            return nil
        }
        
        let dataRows = Array(lines.dropFirst())
        
        // Take first 5 rows as sample
        let sampleRows = Array(dataRows.prefix(5)).map { parseCSVRow($0, separator: separator) }
        
        return (headers: header, sampleRows: sampleRows, totalRows: dataRows.count)
    }
    
    // MARK: - Format Detection
    
    private enum CSVFormat {
        case custom
        case smartSpend
    }
    
    private func detectCSVFormat(header: [String]) -> CSVFormat {
        let normalizedHeader = header.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // SmartSpend format detection
        if normalizedHeader.contains("date") && normalizedHeader.contains("title") && normalizedHeader.contains("amount") && normalizedHeader.contains("category") {
            return .smartSpend
        }
        
        return .custom
    }
    

    
    // MARK: - Helper Methods
    
    private func parseExpenseFromRow(_ columns: [String], header: [String], format: CSVFormat, categoryMap: [String: UUID]) throws -> Expense {
        switch format {
        case .smartSpend:
            return try parseSmartSpendRow(columns: columns, header: header, categoryMap: categoryMap)
        case .custom:
            return try parseCustomRow(columns: columns, header: header, categoryMap: categoryMap)
        }
    }
    
    
    private func parseSmartSpendRow(columns: [String], header: [String], categoryMap: [String: UUID]) throws -> Expense {
        guard let dateIndex = header.firstIndex(where: { $0.lowercased() == "date" }),
              let titleIndex = header.firstIndex(where: { $0.lowercased() == "title" }),
              let amountIndex = header.firstIndex(where: { $0.lowercased() == "amount" }),
              let categoryIndex = header.firstIndex(where: { $0.lowercased() == "category" }) else {
            throw ImportError.missingColumns
        }
        
        // Check if columns array has enough elements
        guard columns.count > max(dateIndex, titleIndex, amountIndex, categoryIndex) else {
            throw ImportError.invalidData("Row has insufficient columns (expected \(header.count), got \(columns.count))")
        }
        
        let title = columns[titleIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let amountString = columns[amountIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let categoryString = columns[categoryIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        let dateString = columns[dateIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let amount = parseAmount(amountString) else {
            throw ImportError.invalidData("Invalid amount: '\(amountString)'")
        }
        
        let date = parseDate(dateString) ?? Date()
        
        // Parse category and find/assign userCategoryId
        let (category, userCategoryId) = parseCategoryWithMap(categoryString, categoryMap: categoryMap)
        
        // Title is allowed to be empty now - will be flagged as problem expense
        return Expense(title: title, amount: amount, category: category, userCategoryId: userCategoryId, date: date)
    }
    
    private func parseCustomRow(columns: [String], header: [String], categoryMap: [String: UUID]) throws -> Expense {
        // Try to intelligently map columns
        var title = ""
        var amount: Double = 0
        var date = Date()
        var categoryString = ""
        
        // First, try to match columns using header names
        var foundTitle = false
        var foundAmount = false
        
        for (index, columnName) in header.enumerated() {
            guard index < columns.count else { break }
            
            let value = columns[index].trimmingCharacters(in: .whitespacesAndNewlines)
            let lowerColName = columnName.lowercased()
            
            // Try to match column names
            if lowerColName.contains("title") || lowerColName.contains("name") || lowerColName.contains("description") {
                title = value
                foundTitle = true
            } else if lowerColName.contains("amount") || lowerColName.contains("price") || lowerColName.contains("cost") {
                if let parsedAmount = parseAmount(value) {
                    amount = parsedAmount
                    foundAmount = true
                }
            } else if lowerColName.contains("date") {
                if let parsedDate = parseDate(value) {
                    date = parsedDate
                }
            } else if lowerColName.contains("category") || lowerColName.contains("type") {
                categoryString = value
            }
        }
        
        // If we couldn't find columns by header name, try positional parsing
        // Common formats: [title, amount, category, date] or [title, amount, date, category]
        if !foundTitle || !foundAmount {
            if columns.count >= 4 {
                // Try to parse as [title, amount, category, date]
                let col0 = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let col1 = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let col2 = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let col3 = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Check if col1 looks like an amount
                if let parsedAmount = parseAmount(col1), parsedAmount > 0 {
                    title = col0
                    amount = parsedAmount
                    
                    // Try to determine if col2 is category or date
                    if parseDate(col2) != nil {
                        // col2 is date, col3 might be category
                        date = parseDate(col2) ?? Date()
                        categoryString = col3
                    } else {
                        // col2 is probably category, col3 should be date
                        categoryString = col2
                        date = parseDate(col3) ?? Date()
                    }
                }
            }
        }
        
        guard amount > 0 else {
            throw ImportError.invalidData("Amount must be greater than zero")
        }
        
        // Parse category and find/assign userCategoryId
        let (category, userCategoryId) = parseCategoryWithMap(categoryString, categoryMap: categoryMap)
        
        // Title is allowed to be empty now - will be flagged as problem expense
        return Expense(title: title, amount: amount, category: category, userCategoryId: userCategoryId, date: date)
    }
    
    enum ImportError: Error, LocalizedError {
        case missingColumns
        case invalidData(String)
        
        var errorDescription: String? {
            switch self {
            case .missingColumns:
                return "Required columns are missing from the CSV file"
            case .invalidData(let message):
                return message
            }
        }
    }
    
    private func parseCSVRow(_ row: String, separator: Character = ",") -> [String] {
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
            } else if char == separator && !insideQuotes {
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
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle empty values
        guard !trimmed.isEmpty else {
            return nil
        }
        
        // Remove currency symbols, commas, spaces, and keep only numbers, dots, and minus
        var cleaned = trimmed
        
        // Handle common currency symbols
        cleaned = cleaned.replacingOccurrences(of: "$", with: "")
        cleaned = cleaned.replacingOccurrences(of: "€", with: "")
        cleaned = cleaned.replacingOccurrences(of: "£", with: "")
        cleaned = cleaned.replacingOccurrences(of: "¥", with: "")
        cleaned = cleaned.replacingOccurrences(of: "₽", with: "")
        cleaned = cleaned.replacingOccurrences(of: "₹", with: "")
        cleaned = cleaned.replacingOccurrences(of: ",", with: "")
        cleaned = cleaned.replacingOccurrences(of: " ", with: "")
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle parentheses for negative numbers (accounting format)
        if cleaned.hasPrefix("(") && cleaned.hasSuffix(")") {
            cleaned = "-" + cleaned.dropFirst().dropLast()
        }
        
        // Keep only numbers, dots, and minus
        cleaned = cleaned.replacingOccurrences(of: "[^0-9.-]", with: "", options: .regularExpression)
        
        // Handle empty after cleaning
        guard !cleaned.isEmpty else {
            return nil
        }
        
        // Try to parse as double
        guard let amount = Double(cleaned) else {
            return nil
        }
        
        // Take absolute value (amounts are always positive in expenses)
        let positiveAmount = abs(amount)
        
        // Validate amount is not zero
        guard positiveAmount > 0 else {
            return nil
        }
        
        return positiveAmount
    }
    
    private func parseDate(_ value: String) -> Date? {
        let cleanedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If empty, use today's date as fallback
        if cleanedValue.isEmpty {
            return nil
        }
        
        // Try numeric timestamp first (Unix timestamp in seconds or milliseconds)
        if let timestamp = Double(cleanedValue) {
            // Very rough check to ensure it's not just a small number like "1" or "10"
            if timestamp > 1_000_000_000 {
                if timestamp > 1_000_000_000_000 {
                    // Milliseconds
                    return Date(timeIntervalSince1970: timestamp / 1000)
                } else {
                    // Seconds
                    return Date(timeIntervalSince1970: timestamp)
                }
            }
        }
        
        let formatters: [DateFormatter] = [
            // Most common formats first
            createDateFormatter("yyyy-MM-dd"),
            createDateFormatter("MM/dd/yyyy"),
            createDateFormatter("dd/MM/yyyy"),
            createDateFormatter("M/d/yyyy"),
            createDateFormatter("d/M/yyyy"),
            createDateFormatter("yyyy/MM/dd"),
            createDateFormatter("dd-MM-yyyy"),
            createDateFormatter("dd.MM.yyyy"),
            createDateFormatter("MM-dd-yyyy"),
            createDateFormatter("M-d-yyyy"),
            createDateFormatter("d-M-yyyy"),
            createDateFormatter("yyyy.MM.dd"),
            // With times
            createDateFormatter("yyyy-MM-dd HH:mm:ss"),
            createDateFormatter("MM/dd/yyyy HH:mm:ss"),
            createDateFormatter("dd/MM/yyyy HH:mm:ss"),
            createDateFormatter("M/d/yyyy HH:mm:ss"),
            createDateFormatter("yyyy-MM-dd HH:mm"),
            createDateFormatter("MM/dd/yyyy HH:mm"),
            // ISO formats
            createDateFormatter("yyyy-MM-dd'T'HH:mm:ss"),
            createDateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS"),
            createDateFormatter("yyyy-MM-dd'T'HH:mm:ss'Z'"),
            createDateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSSZ"),
            createDateFormatter("yyyy-MM-dd'T'HH:mm:ssZ")
        ]
        
        for formatter in formatters {
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone.current
            if let date = formatter.date(from: cleanedValue) {
                return date
            }
        }
        
        // Try parsing with locale-aware date strings
        let localeFormatters: [DateFormatter] = [
            createDateFormatter("MMM dd, yyyy"),
            createDateFormatter("MMMM dd, yyyy"),
            createDateFormatter("dd MMM yyyy"),
            createDateFormatter("dd MMMM yyyy"),
            createDateFormatter("MMM dd yyyy"),
            createDateFormatter("MMMM dd yyyy"),
            createDateFormatter("dd-MMM-yyyy"),
            createDateFormatter("dd.MMM.yyyy")
        ]
        
        for formatter in localeFormatters {
            formatter.locale = Locale(identifier: "en_US")
            if let date = formatter.date(from: cleanedValue) {
                return date
            }
        }
        
        // Try ISO8601DateFormatter for ISO format dates
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: cleanedValue) {
            return date
        }
        
        return nil
    }
    
    private func createDateFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }
    
    // Extract category string from CSV row without parsing it
    private func extractCategoryString(_ columns: [String], header: [String], format: CSVFormat) -> String? {
        switch format {
        case .smartSpend:
            if let categoryIndex = header.firstIndex(where: { $0.lowercased() == "category" }),
               categoryIndex < columns.count {
                return columns[categoryIndex]
            }
        case .custom:
            if let categoryIndex = header.firstIndex(where: { $0.lowercased().contains("category") || $0.lowercased().contains("type") }),
               categoryIndex < columns.count {
                return columns[categoryIndex]
            }
        }
        return nil
    }
    
    private func parseCategoryWithMap(_ categoryString: String, categoryMap: [String: UUID]) -> (ExpenseCategory, UUID?) {
        let normalized = categoryString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if normalized.isEmpty {
            return (.other, nil)
        }
        
        // Validation: If the category string parses as a valid date, it's likely a mapping error
        if parseDate(categoryString) != nil {
            print("⚠️ Warning: Category value '\(categoryString)' looks like a date. Ignoring to prevent miscategorization.")
            return (.other, nil)
        }
        
        // Check if it matches a built-in category
        if let exactMatch = ExpenseCategory.allCases.first(where: { $0.rawValue.lowercased() == normalized }) {
            return (exactMatch, nil)
        }
        
        // Look up the UserCategory ID from the map
        if let id = categoryMap[normalized] {
            return (.other, id)
        }
        
        print("⚠️ Warning: Category '\(categoryString)' (normalized: '\(normalized)') not found in map or built-in categories. Falling back to Other.")
        return (.other, nil)
    }
}
