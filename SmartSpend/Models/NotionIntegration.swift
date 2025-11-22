import Foundation
import UserNotifications

// MARK: - Notion API Models
struct NotionDatabase: Codable {
    let id: String
    let title: [NotionText]
    let properties: [String: NotionProperty]
}

struct NotionText: Codable {
    let plain_text: String
}

struct NotionProperty: Codable {
    let type: String
    let title: [NotionText]?
    let number: Double?
    let select: NotionSelect?
    let date: NotionDate?
    let rich_text: [NotionText]?
}

struct NotionSelect: Codable {
    let name: String
}

struct NotionDate: Codable {
    let start: String
}

struct NotionPage: Codable {
    let id: String
    let properties: [String: NotionProperty]
    let created_time: String
    let last_edited_time: String
}

struct NotionQueryResponse: Codable {
    let results: [NotionPage]
    let has_more: Bool
    let next_cursor: String?
}

// MARK: - Notion Integration Manager
class NotionIntegrationManager: ObservableObject {
    static let shared = NotionIntegrationManager()
    
    @Published var isConnected = false
    @Published var lastSyncDate: Date?
    @Published var isSyncing = false
    @Published var lastNotionUpdateTime: Date?
    @Published var syncStatus: String = "Not connected"
    @Published var isAutoSyncEnabled = false
    @Published var autoSyncStartDate: Date?
    
    private let baseURL = "https://api.notion.com/v1"
    private var apiKey: String = ""
    private var databaseId: String = ""
    private var syncTimer: Timer?
    // Removed UIBackgroundTaskIdentifier as it's not available in SwiftUI
    
    // Track Notion expenses for real-time sync
    private var notionExpenseIds: Set<String> = []
    private var lastDatabaseUpdateTime: Date?
    
    private init() {
        loadSettings()
    }
    
    // MARK: - Settings Management
    func configure(apiKey: String, databaseId: String) {
        self.apiKey = apiKey
        self.databaseId = databaseId
        self.isConnected = !apiKey.isEmpty && !databaseId.isEmpty
        saveSettings()
    }
    
    func disconnect() {
        self.apiKey = ""
        self.databaseId = ""
        self.isConnected = false
        saveSettings()
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(apiKey, forKey: "notion_api_key")
        UserDefaults.standard.set(databaseId, forKey: "notion_database_id")
        UserDefaults.standard.set(isConnected, forKey: "notion_is_connected")
        if let lastSync = lastSyncDate {
            UserDefaults.standard.set(lastSync, forKey: "notion_last_sync_date")
        }
        if let lastUpdate = lastNotionUpdateTime {
            UserDefaults.standard.set(lastUpdate, forKey: "notion_last_update_time")
        }
        UserDefaults.standard.set(isAutoSyncEnabled, forKey: "notion_auto_sync_enabled")
        if let autoSyncStart = autoSyncStartDate {
            UserDefaults.standard.set(autoSyncStart, forKey: "notion_auto_sync_start_date")
        }
    }
    
    private func loadSettings() {
        apiKey = UserDefaults.standard.string(forKey: "notion_api_key") ?? ""
        databaseId = UserDefaults.standard.string(forKey: "notion_database_id") ?? ""
        isConnected = UserDefaults.standard.bool(forKey: "notion_is_connected")
        lastSyncDate = UserDefaults.standard.object(forKey: "notion_last_sync_date") as? Date
        lastNotionUpdateTime = UserDefaults.standard.object(forKey: "notion_last_update_time") as? Date
        isAutoSyncEnabled = UserDefaults.standard.bool(forKey: "notion_auto_sync_enabled")
        autoSyncStartDate = UserDefaults.standard.object(forKey: "notion_auto_sync_start_date") as? Date
    }
    
    // MARK: - API Communication
    func fetchDatabaseSchema() async throws {
        guard isConnected else {
            throw NotionError.notConfigured
        }
        
        let url = URL(string: "\(baseURL)/databases/\(databaseId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NotionError.apiError("Invalid HTTP response")
        }
        
        if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NotionError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        // Print the database schema
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🏗️ Database Schema:")
            print(jsonString)
        }
    }
    
    func fetchRecentExpenses() async throws -> [NotionPage] {
        guard isConnected else {
            throw NotionError.notConfigured
        }
        
        let url = URL(string: "\(baseURL)/databases/\(databaseId)/query")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Query for recent entries (last 30 days)
        let query: [String: Any] = [
            "filter": [
                "property": "Date",
                "date": [
                    "on_or_after": ISO8601DateFormatter().string(from: Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date())
                ]
            ],
            "sorts": [
                [
                    "property": "Date",
                    "direction": "descending"
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: query)
        
        // Retry logic for network issues
        var lastError: Error?
        for attempt in 1...3 {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NotionError.apiError("Invalid HTTP response")
                }
                
                if httpResponse.statusCode == 403 {
                    throw NotionError.apiError("Access denied (403). Please check if the database is shared with your integration.")
                } else if httpResponse.statusCode != 200 {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    throw NotionError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
                }
                
                let notionResponse = try JSONDecoder().decode(NotionQueryResponse.self, from: data)
                return notionResponse.results
                
            } catch {
                lastError = error
                if attempt < 3 {
                    print("⚠️ Notion API attempt \(attempt) failed, retrying...")
                    try await Task.sleep(nanoseconds: UInt64(attempt * 2) * 1_000_000_000) // Wait 2, 4 seconds
                }
            }
        }
        
        throw lastError ?? NotionError.apiError("Failed after 3 attempts")
    }
    
    /// Fetch only expenses that have been created or modified since a specific date
    func fetchExpensesSince(_ date: Date) async throws -> [NotionPage] {
        guard isConnected else {
            throw NotionError.notConfigured
        }
        
        let url = URL(string: "\(baseURL)/databases/\(databaseId)/query")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: date)
        
        // Query for entries created or modified after the specified date
        let query: [String: Any] = [
            "filter": [
                "or": [
                    [
                        "property": "Date",
                        "date": [
                            "after": dateString
                        ]
                    ],
                    [
                        "timestamp": "last_edited_time",
                        "last_edited_time": [
                            "after": dateString
                        ]
                    ]
                ]
            ],
            "sorts": [
                [
                    "property": "Date",
                    "direction": "descending"
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: query)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NotionError.apiError("Invalid HTTP response")
        }
        
        if httpResponse.statusCode == 403 {
            throw NotionError.apiError("Access denied (403). Please check if the database is shared with your integration.")
        } else if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NotionError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        let notionResponse = try JSONDecoder().decode(NotionQueryResponse.self, from: data)
        return notionResponse.results
    }
    
    /// Fetch expenses created in Notion after a specific date (for auto-sync)
    func fetchExpensesCreatedAfter(_ date: Date) async throws -> [NotionPage] {
        guard isConnected else {
            throw NotionError.notConfigured
        }
        
        let url = URL(string: "\(baseURL)/databases/\(databaseId)/query")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: date)
        
        // Query for entries created after the specified date (using created_time)
        let query: [String: Any] = [
            "filter": [
                "timestamp": "created_time",
                "created_time": [
                    "after": dateString
                ]
            ],
            "sorts": [
                [
                    "timestamp": "created_time",
                    "direction": "descending"
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: query)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NotionError.apiError("Invalid HTTP response")
        }
        
        if httpResponse.statusCode == 403 {
            throw NotionError.apiError("Access denied (403). Please check if the database is shared with your integration.")
        } else if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NotionError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        let notionResponse = try JSONDecoder().decode(NotionQueryResponse.self, from: data)
        return notionResponse.results
    }
    
    /// Fetch expenses updated in Notion after a specific date (for auto-sync updates)
    func fetchExpensesUpdatedAfter(_ date: Date) async throws -> [NotionPage] {
        guard isConnected else {
            throw NotionError.notConfigured
        }
        
        let url = URL(string: "\(baseURL)/databases/\(databaseId)/query")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: date)
        
        // Query for entries updated after the specified date (using last_edited_time)
        let query: [String: Any] = [
            "filter": [
                "timestamp": "last_edited_time",
                "last_edited_time": [
                    "after": dateString
                ]
            ],
            "sorts": [
                [
                    "timestamp": "last_edited_time",
                    "direction": "descending"
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: query)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NotionError.apiError("Invalid HTTP response")
        }
        
        if httpResponse.statusCode == 403 {
            throw NotionError.apiError("Access denied (403). Please check if the database is shared with your integration.")
        } else if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NotionError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        let notionResponse = try JSONDecoder().decode(NotionQueryResponse.self, from: data)
        return notionResponse.results
    }
    
    /// Fetch all current expenses from Notion (for detecting deletions)
    func fetchAllCurrentExpenses() async throws -> [NotionPage] {
        guard isConnected else {
            throw NotionError.notConfigured
        }
        
        let url = URL(string: "\(baseURL)/databases/\(databaseId)/query")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Query for all entries (no filter)
        let query: [String: Any] = [
            "sorts": [
                [
                    "timestamp": "created_time",
                    "direction": "descending"
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: query)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NotionError.apiError("Invalid HTTP response")
        }
        
        if httpResponse.statusCode == 403 {
            throw NotionError.apiError("Access denied (403). Please check if the database is shared with your integration.")
        } else if httpResponse.statusCode != 200 {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NotionError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        let notionResponse = try JSONDecoder().decode(NotionQueryResponse.self, from: data)
        return notionResponse.results
    }
    
    // MARK: - Data Conversion
    func convertNotionPageToExpense(_ page: NotionPage) -> Expense? {
        let properties = page.properties
        print("   📋 Available properties: \(properties.keys.joined(separator: ", "))")
        
        // Extract title
        guard let titleProperty = properties["Expense"] ?? properties["Title"] ?? properties["Name"] else {
            print("   ❌ No Expense, Title, or Name property found")
            return nil
        }
        
        guard let title = titleProperty.title?.first?.plain_text else {
            print("   ❌ No title text found in Title/Name property")
            return nil
        }
        print("   ✅ Title: \(title)")
        
        // Extract amount
        guard let amountProperty = properties["Amount"] ?? properties["Price"] else {
            print("   ❌ No Amount or Price property found")
            return nil
        }
        
        guard let amount = amountProperty.number else {
            print("   ❌ No amount value found in Amount/Price property")
            return nil
        }
        print("   ✅ Amount: \(amount)")
        
        // Extract category
        let categoryName = properties["Category"]?.select?.name ?? "Other"
        let category = ExpenseCategory.allCases.first { $0.rawValue.lowercased() == categoryName.lowercased() } ?? .other
        print("   ✅ Category: \(categoryName) -> \(category.rawValue)")
        
        // Extract date
        let dateString = properties["Date"]?.date?.start ?? page.created_time
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: dateString) ?? Date()
        print("   ✅ Date: \(dateString) -> \(date)")
        
        return Expense(
            title: title,
            amount: amount,
            category: category,
            date: date
        )
    }
    
    // MARK: - Auto Sync Operations
    
    /// Enable auto-sync - only imports expenses created after this point
    func enableAutoSync() {
        guard isConnected else { return }
        
        isAutoSyncEnabled = true
        autoSyncStartDate = Date()
        saveSettings()
        
        // Start the sync timer
        startAutoSyncTimer()
        
        print("🔄 Auto-sync enabled - will only import expenses created after \(autoSyncStartDate?.formatted() ?? "now")")
        syncStatus = "Auto-sync enabled"
    }
    
    /// Disable auto-sync
    func disableAutoSync() {
        isAutoSyncEnabled = false
        autoSyncStartDate = nil
        saveSettings()
        
        // Stop the sync timer
        stopAutoSyncTimer()
        
        print("⏹️ Auto-sync disabled")
        syncStatus = "Auto-sync disabled"
    }
    
    /// Start the auto-sync timer
    private func startAutoSyncTimer() {
        // Stop existing timer
        syncTimer?.invalidate()
        
        // Start new timer - check every 30 seconds for changes
        syncTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task {
                await self?.performAutoSync()
            }
        }
        
        // Initial sync to establish baseline
        Task {
            await performAutoSync()
        }
    }
    
    /// Stop the auto-sync timer
    private func stopAutoSyncTimer() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
    

    
    /// Perform auto-sync - handles creates, updates, and deletes after auto-sync was enabled
    func performAutoSync() async {
        guard isConnected && isAutoSyncEnabled else { return }
        
        await MainActor.run {
            isSyncing = true
            syncStatus = "Auto-syncing..."
        }
        
        do {
            guard let autoSyncStart = autoSyncStartDate else {
                await MainActor.run {
                    isSyncing = false
                    syncStatus = "Auto-sync not properly initialized"
                }
                return
            }
            
            let dataManager = DataManager.shared
            var addedCount = 0
            var updatedCount = 0
            var deletedCount = 0
            
            // 1. Handle NEW expenses (created after auto-sync was enabled)
            let newExpenses = try await fetchExpensesCreatedAfter(autoSyncStart)
            print("📊 Auto-sync: Found \(newExpenses.count) expenses created after auto-sync was enabled")
            
            for page in newExpenses {
                if let expense = convertNotionPageToExpense(page) {
                    // Check if expense already exists by Notion ID
                    let existingExpense = dataManager.expenses.first { existing in
                        existing.notionId == page.id
                    }
                    
                    if existingExpense == nil {
                        // Add new expense
                        await MainActor.run {
                            let newExpense = Expense(
                                title: expense.title,
                                amount: expense.amount,
                                category: expense.category,
                                date: expense.date,
                                notionId: page.id
                            )
                            dataManager.addExpense(newExpense)
                        }
                        addedCount += 1
                        print("➕ Added new expense: \(expense.title)")
                        
                        // Show notification for new expense
                        await showNewExpenseNotification(expense)
                    }
                }
            }
            
            // 2. Handle UPDATED expenses (modified after auto-sync was enabled)
            let updatedExpenses = try await fetchExpensesUpdatedAfter(autoSyncStart)
            print("📊 Auto-sync: Found \(updatedExpenses.count) expenses updated after auto-sync was enabled")
            
            for page in updatedExpenses {
                if let expense = convertNotionPageToExpense(page) {
                    // Find existing expense by Notion ID
                    if let existingIndex = dataManager.expenses.firstIndex(where: { $0.notionId == page.id }) {
                        // Update existing expense
                        await MainActor.run {
                            var updatedExpense = Expense(
                                title: expense.title,
                                amount: expense.amount,
                                category: expense.category,
                                date: expense.date,
                                notionId: page.id
                            )
                            updatedExpense.id = dataManager.expenses[existingIndex].id // Keep the same ID
                            dataManager.expenses[existingIndex] = updatedExpense
                        }
                        updatedCount += 1
                        print("🔄 Updated expense: \(expense.title)")
                    }
                }
            }
            
            // 3. Handle DELETED expenses (expenses that exist in app but not in Notion)
            let allCurrentNotionExpenses = try await fetchAllCurrentExpenses()
            let currentNotionIds = Set(allCurrentNotionExpenses.map { $0.id })
            
            // Find expenses in app that have Notion IDs but no longer exist in Notion
            let expensesToDelete = dataManager.expenses.filter { expense in
                if let notionId = expense.notionId {
                    return !currentNotionIds.contains(notionId)
                }
                return false
            }
            
            for expense in expensesToDelete {
                await MainActor.run {
                    dataManager.deleteExpense(expense)
                }
                deletedCount += 1
                print("🗑️ Deleted expense: \(expense.title)")
            }
            
            // Update tracking
            lastDatabaseUpdateTime = Date()
            
            // Capture the counts before the async block to avoid Swift 6 concurrency issues
            let finalAddedCount = addedCount
            let finalUpdatedCount = updatedCount
            let finalDeletedCount = deletedCount
            
            await MainActor.run {
                lastSyncDate = Date()
                isSyncing = false
                
                let status = "Added: \(finalAddedCount), Updated: \(finalUpdatedCount), Deleted: \(finalDeletedCount)"
                syncStatus = status
                
                print("✅ Auto-sync completed - \(status)")
            }
            
        } catch {
            print("❌ Auto-sync error: \(error)")
            await MainActor.run {
                isSyncing = false
                syncStatus = "Auto-sync failed: \(error.localizedDescription)"
            }
        }
    }
    
    /// Check if database has been updated since last sync
    private func checkDatabaseUpdates() async throws -> Bool {
        guard let lastSync = lastSyncDate else {
            // First time sync, always sync
            return true
        }
        
        // Query for entries created or modified after last sync
        let query: [String: Any] = [
            "filter": [
                "or": [
                    [
                        "property": "Date",
                        "date": [
                            "after": ISO8601DateFormatter().string(from: lastSync)
                        ]
                    ],
                    [
                        "timestamp": "last_edited_time",
                        "last_edited_time": [
                            "after": ISO8601DateFormatter().string(from: lastSync)
                        ]
                    ]
                ]
            ],
            "sorts": [
                [
                    "property": "Date",
                    "direction": "descending"
                ]
            ],
            "page_size": 1
        ]
        
        let url = URL(string: "\(baseURL)/databases/\(databaseId)/query")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONSerialization.data(withJSONObject: query)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NotionError.apiError("Failed to check database updates")
        }
        
        let notionResponse = try JSONDecoder().decode(NotionQueryResponse.self, from: data)
        return !notionResponse.results.isEmpty
    }
    
    /// Smart sync that only processes new expenses
    func smartSyncExpenses() async {
        guard isConnected else { return }
        
        await MainActor.run {
            isSyncing = true
        }
        
        do {
            let notionPages = try await fetchRecentExpenses()
            print("📊 Found \(notionPages.count) pages in Notion database")
            
            // Filter for pages created after last sync
            let newPages = notionPages.filter { page in
                guard let lastSync = lastSyncDate else { 
                    // If no last sync date, only import expenses created in the last 24 hours
                    // This prevents importing all historical data when sync date is cleared
                    let dateFormatter = ISO8601DateFormatter()
                    if let createdDate = dateFormatter.date(from: page.created_time) {
                        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? Date()
                        return createdDate > twentyFourHoursAgo
                    }
                    return false
                }
                
                let dateFormatter = ISO8601DateFormatter()
                if let createdDate = dateFormatter.date(from: page.created_time) {
                    return createdDate > lastSync
                }
                return false
            }
            
            print("🆕 Found \(newPages.count) new pages since last sync")
            
            if newPages.isEmpty {
                await MainActor.run {
                    isSyncing = false
                }
                return
            }
            
            let dataManager = DataManager.shared
            var newExpensesCount = 0
            
            // Convert and add new expenses
            for (index, page) in newPages.enumerated() {
                print("🔍 Processing new page \(index + 1)/\(newPages.count): \(page.id)")
                
                if let expense = convertNotionPageToExpense(page) {
                    print("✅ Successfully converted: \(expense.title) - $\(expense.amount)")
                    
                    // Enhanced duplicate detection - check multiple criteria
                    let existingExpense = dataManager.expenses.first { existing in
                        // Primary check: exact title and amount match
                        let titleAndAmountMatch = existing.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == expense.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) &&
                        abs(existing.amount - expense.amount) < 0.01 // Allow for small rounding differences
                        
                        if titleAndAmountMatch {
                            // If title and amount match, check if dates are close (within 24 hours)
                            let dateDifference = abs(existing.date.timeIntervalSince(expense.date))
                            let isWithin24Hours = dateDifference < 86400 // 24 hours in seconds
                            
                            print("🔍 Duplicate check - Title/Amount match: \(titleAndAmountMatch), Date diff: \(dateDifference/3600) hours, Within 24h: \(isWithin24Hours)")
                            
                            return isWithin24Hours
                        }
                        
                        return false
                    }
                    
                    if existingExpense == nil {
                        print("➕ Adding new expense: \(expense.title)")
                        await MainActor.run {
                            dataManager.addExpense(expense)
                        }
                        newExpensesCount += 1
                        
                        // Show notification for new expense
                        await showNewExpenseNotification(expense)
                    } else {
                        print("⚠️ Expense already exists: \(expense.title)")
                    }
                } else {
                    print("❌ Failed to convert page \(index + 1): \(page.id)")
                    print("   Properties: \(page.properties.keys.joined(separator: ", "))")
                }
            }
            
            let finalCount = newExpensesCount
            await MainActor.run {
                lastSyncDate = Date()
                isSyncing = false
                
                // Show notification if new expenses were added
                if finalCount > 0 {
                    print("✅ Synced \(finalCount) new expenses from Notion")
                } else {
                    print("✅ Sync completed - no new expenses found")
                }
            }
            
        } catch {
            print("❌ Notion sync error: \(error)")
            await MainActor.run {
                isSyncing = false
            }
        }
    }
    
    /// Show notification for new expense
    private func showNewExpenseNotification(_ expense: Expense) async {
        await MainActor.run {
            // Create a simple notification
            let content = UNMutableNotificationContent()
            content.title = "New Expense Added"
            content.body = "\(expense.title) - $\(String(format: "%.2f", expense.amount))"
            content.sound = .default
            
            let request = UNNotificationRequest(
                identifier: "notion-expense-\(expense.id)",
                content: content,
                trigger: nil
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Failed to show notification: \(error)")
                }
            }
        }
    }
    
    // MARK: - Sync Management
    
    /// Clear last sync date - useful after CSV import to force re-sync
    func clearLastSyncDate() {
        lastSyncDate = nil
        UserDefaults.standard.removeObject(forKey: "notion_last_sync_date")
        print("🔄 Last sync date cleared - next sync will check all expenses")
    }
    
    // MARK: - Legacy Sync (for manual sync)
    func syncExpenses() async {
        guard isConnected else { return }
        
        await MainActor.run {
            isSyncing = true
        }
        
        do {
            let notionPages = try await fetchRecentExpenses()
            print("📊 Found \(notionPages.count) pages in Notion database")
            
            let dataManager = DataManager.shared
            var newExpensesCount = 0
            
            // Filter for pages created after last sync (for legacy sync)
            let newPages = notionPages.filter { page in
                guard let lastSync = lastSyncDate else { 
                    // If no last sync date, only import expenses created in the last 24 hours
                    // This prevents importing all historical data when sync date is cleared
                    let dateFormatter = ISO8601DateFormatter()
                    if let createdDate = dateFormatter.date(from: page.created_time) {
                        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? Date()
                        return createdDate > twentyFourHoursAgo
                    }
                    return false
                }
                
                let dateFormatter = ISO8601DateFormatter()
                if let createdDate = dateFormatter.date(from: page.created_time) {
                    return createdDate > lastSync
                }
                return false
            }
            
            // Convert and add new expenses
            for (index, page) in newPages.enumerated() {
                print("🔍 Processing page \(index + 1)/\(newPages.count): \(page.id)")
                
                if let expense = convertNotionPageToExpense(page) {
                    print("✅ Successfully converted: \(expense.title) - $\(expense.amount)")
                    
                    // Enhanced duplicate detection - check multiple criteria
                    let existingExpense = dataManager.expenses.first { existing in
                        // Primary check: exact title and amount match
                        let titleAndAmountMatch = existing.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == expense.title.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) &&
                        abs(existing.amount - expense.amount) < 0.01 // Allow for small rounding differences
                        
                        if titleAndAmountMatch {
                            // If title and amount match, check if dates are close (within 24 hours)
                            let dateDifference = abs(existing.date.timeIntervalSince(expense.date))
                            let isWithin24Hours = dateDifference < 86400 // 24 hours in seconds
                            
                            print("🔍 Duplicate check - Title/Amount match: \(titleAndAmountMatch), Date diff: \(dateDifference/3600) hours, Within 24h: \(isWithin24Hours)")
                            
                            return isWithin24Hours
                        }
                        
                        return false
                    }
                    
                    if existingExpense == nil {
                        print("➕ Adding new expense: \(expense.title)")
                        await MainActor.run {
                            dataManager.addExpense(expense)
                        }
                        newExpensesCount += 1
                    } else {
                        print("⚠️ Expense already exists: \(expense.title)")
                    }
                } else {
                    print("❌ Failed to convert page \(index + 1): \(page.id)")
                    print("   Properties: \(page.properties.keys.joined(separator: ", "))")
                }
            }
            
            let finalCount = newExpensesCount
            await MainActor.run {
                lastSyncDate = Date()
                isSyncing = false
                
                // Show notification if new expenses were added
                if finalCount > 0 {
                    print("✅ Synced \(finalCount) new expenses from Notion")
                } else {
                    print("✅ Sync completed - no new expenses found")
                }
            }
            
        } catch {
            print("❌ Notion sync error: \(error)")
            await MainActor.run {
                isSyncing = false
            }
        }
    }
}

// MARK: - Errors
enum NotionError: Error, LocalizedError {
    case notConfigured
    case apiError(String)
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Notion integration is not configured"
        case .apiError(let message):
            return "API Error: \(message)"
        case .invalidData:
            return "Invalid data received from Notion"
        }
    }
}

