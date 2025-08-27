import SwiftUI

struct NotionIntegrationView: View {
    @ObservedObject private var notionManager = NotionIntegrationManager.shared
    @State private var apiKey = ""
    @State private var databaseId = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isTestingConnection = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "link.badge.plus")
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)
                        
                        Text("Notion Integration")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Connect your Notion expense database to automatically sync expenses to SmartSpend")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Connection Status
                    connectionStatusCard
                    
                    // Configuration Form
                    if !notionManager.isConnected {
                        configurationForm
                    }
                    
                    // Sync Controls
                    if notionManager.isConnected {
                        syncControls
                    }
                    
                    // Instructions
                    instructionsCard
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Notion Integration")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Notion Integration", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                loadCurrentSettings()
            }
        }
    }
    
    private var connectionStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: notionManager.isConnected ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(notionManager.isConnected ? .green : .red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notionManager.isConnected ? "Connected" : "Not Connected")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if notionManager.isConnected {
                        Text("Last sync: \(lastSyncText)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if notionManager.isConnected {
                    Button("Disconnect") {
                        notionManager.disconnect()
                        loadCurrentSettings()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.red)
                }
            }
            
            if notionManager.isSyncing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Syncing with Notion...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var configurationForm: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("API Key")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                SecureField("Enter your Notion API key", text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                
                Text("Get your API key from [Notion Integrations](https://www.notion.so/my-integrations)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Database ID")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                TextField("Enter your database ID", text: $databaseId)
                    .textFieldStyle(.roundedBorder)
                
                Text("Find your database ID in the URL: notion.so/workspace/DATABASE-ID")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Button(action: testConnection) {
                HStack {
                    if isTestingConnection {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "link")
                    }
                    Text(isTestingConnection ? "Testing..." : "Test Connection")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
                .fontWeight(.semibold)
            }
            .disabled(apiKey.isEmpty || databaseId.isEmpty || isTestingConnection)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var syncControls: some View {
        VStack(spacing: 16) {
            // Auto-Sync Toggle
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Auto-Sync")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(notionManager.isAutoSyncEnabled ? "Enabled" : "Disabled")
                            .font(.subheadline)
                            .foregroundStyle(notionManager.isAutoSyncEnabled ? .green : .secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { notionManager.isAutoSyncEnabled },
                        set: { isEnabled in
                            if isEnabled {
                                notionManager.enableAutoSync()
                            } else {
                                notionManager.disableAutoSync()
                            }
                        }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                
                if notionManager.isAutoSyncEnabled {
                    if let startDate = notionManager.autoSyncStartDate {
                        Text("Auto-sync enabled on \(startDate.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("Only expenses created after this time will be imported")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Enable to automatically import new expenses from Notion")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Sync Status
            if notionManager.isAutoSyncEnabled {
                HStack {
                    Image(systemName: notionManager.isSyncing ? "arrow.triangle.2.circlepath" : "checkmark.circle.fill")
                        .foregroundStyle(notionManager.isSyncing ? .orange : .green)
                        .rotationEffect(.degrees(notionManager.isSyncing ? 360 : 0))
                        .animation(notionManager.isSyncing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: notionManager.isSyncing)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Auto-Sync Status")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(notionManager.syncStatus)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background((notionManager.isSyncing ? Color.orange : Color.green).opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
            
            // Check Schema Button
            Button(action: {
                Task {
                    await fetchDatabaseSchema()
                }
            }) {
                HStack {
                    Image(systemName: "info.circle")
                    Text("Check Database Schema")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(.orange, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
                .fontWeight(.semibold)
            }
            .disabled(notionManager.isSyncing)
            
            // Sync Info
            VStack(spacing: 8) {
                if let lastSync = notionManager.lastSyncDate {
                    Text("Last synced: \(lastSync.formatted(.relative(presentation: .named))) ago")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if notionManager.isAutoSyncEnabled {
                    Text("Checking for new expenses every 30 seconds")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Setup Instructions")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                instructionStep(
                    number: "1",
                    title: "Create Notion Integration",
                    description: "Go to notion.so/my-integrations and create a new integration"
                )
                
                instructionStep(
                    number: "2",
                    title: "Share Database",
                    description: "Share your expense database with the integration"
                )
                
                instructionStep(
                    number: "3",
                    title: "Get Database ID",
                    description: "Copy the database ID from the URL (the part after the last slash)"
                )
                
                instructionStep(
                    number: "4",
                    title: "Configure Fields",
                    description: "Ensure your database has: Title, Amount, Category, Date, and Notes fields"
                )
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private func instructionStep(number: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(.blue, in: Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    private var lastSyncText: String {
        guard let lastSync = notionManager.lastSyncDate else {
            return "Never"
        }
        return lastSync.formatted(.relative(presentation: .named))
    }
    
    private func loadCurrentSettings() {
        // Settings are loaded automatically by the manager
    }
    
    private func testConnection() {
        isTestingConnection = true
        
        Task {
            do {
                // Configure temporarily for testing
                notionManager.configure(apiKey: apiKey, databaseId: databaseId)
                
                // Try to fetch data
                _ = try await notionManager.fetchRecentExpenses()
                
                await MainActor.run {
                    alertMessage = "Connection successful! Your Notion database is accessible."
                    showingAlert = true
                    isTestingConnection = false
                }
                
            } catch {
                await MainActor.run {
                    alertMessage = "Connection failed: \(error.localizedDescription)\n\nPlease check:\n• Database is shared with integration\n• Database has required fields (Title, Amount, Category, Date)\n• Integration has proper permissions"
                    showingAlert = true
                    isTestingConnection = false
                    notionManager.disconnect()
                }
            }
        }
    }
    

    
    private func fetchDatabaseSchema() async {
        guard notionManager.isConnected else {
            await MainActor.run {
                alertMessage = "Please connect to Notion first"
                showingAlert = true
            }
            return
        }
        
        do {
            try await notionManager.fetchDatabaseSchema()
            await MainActor.run {
                alertMessage = "Database schema fetched! Check the console for details."
                showingAlert = true
            }
        } catch {
            await MainActor.run {
                alertMessage = "Failed to fetch database schema: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
}

#Preview {
    NotionIntegrationView()
}
