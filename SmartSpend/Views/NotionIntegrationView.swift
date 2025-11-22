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
                        
                        Text("notion_integration_title".localized)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("notion_integration_subtitle".localized)
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
            .navigationTitle("notion_integration_title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .alert("notion_integration_title".localized, isPresented: $showingAlert) {
                Button("ok".localized) { }
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
                    Text(notionManager.isConnected ? "connected".localized : "not_connected".localized)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if notionManager.isConnected {
                        Text(String(format: "last_sync_format".localized, lastSyncText))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if notionManager.isConnected {
                    Button("disconnect".localized) {
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
                    Text("syncing_with_notion".localized)
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
                Text("api_key".localized)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                SecureField("enter_notion_api_key".localized, text: $apiKey)
                    .textFieldStyle(.roundedBorder)
                
                Text("get_api_key_instructions".localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("database_id".localized)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                TextField("enter_database_id".localized, text: $databaseId)
                    .textFieldStyle(.roundedBorder)
                
                Text("find_database_id_instructions".localized)
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
                    Text(isTestingConnection ? "testing".localized : "test_connection".localized)
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
                        Text("auto_sync".localized)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(notionManager.isAutoSyncEnabled ? "enabled".localized : "disabled".localized)
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
                        Text(String(format: "auto_sync_enabled_on".localized, startDate.formatted(date: .abbreviated, time: .shortened)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("auto_sync_after_time_note".localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("enable_auto_sync_hint".localized)
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
                        Text("auto_sync_status".localized)
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
                    Text("check_database_schema".localized)
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
                    Text(String(format: "last_synced_ago".localized, lastSync.formatted(.relative(presentation: .named))))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if notionManager.isAutoSyncEnabled {
                    Text("checking_new_expenses_interval".localized)
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
            Text("setup_instructions".localized)
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                instructionStep(
                    number: "1",
                    title: "create_notion_integration".localized,
                    description: "create_notion_integration_desc".localized
                )
                
                instructionStep(
                    number: "2",
                    title: "share_database".localized,
                    description: "share_database_desc".localized
                )
                
                instructionStep(
                    number: "3",
                    title: "get_database_id".localized,
                    description: "get_database_id_desc".localized
                )
                
                instructionStep(
                    number: "4",
                    title: "configure_fields".localized,
                    description: "configure_fields_desc".localized
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
            return "never".localized
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
                    alertMessage = "connection_success".localized
                    showingAlert = true
                    isTestingConnection = false
                }
                
            } catch {
                await MainActor.run {
                    alertMessage = String(format: "connection_failed_with_suggestions".localized, error.localizedDescription)
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
                alertMessage = "please_connect_notion_first".localized
                showingAlert = true
            }
            return
        }
        
        do {
            try await notionManager.fetchDatabaseSchema()
            await MainActor.run {
                alertMessage = "database_schema_fetched".localized
                showingAlert = true
            }
        } catch {
            await MainActor.run {
                alertMessage = String(format: "failed_fetch_database_schema".localized, error.localizedDescription)
                showingAlert = true
            }
        }
    }
}

#Preview {
    NotionIntegrationView()
}

