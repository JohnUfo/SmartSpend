import SwiftUI

struct MainTabView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var tabManager = TabManager.shared
    
    var body: some View {
        TabView(selection: $tabManager.selectedTab) {
            DashboardView()
                .tabItem {
                    Label("dashboard".localized, systemImage: "house.fill")
                }
                .tag(0)
            
            ExpenseListView()
                .tabItem {
                    Label("expenses".localized, systemImage: "list.bullet.rectangle")
                }
                .tag(1)
            
            AnalyticsView()
                .tabItem {
                    Label("analytics".localized, systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            RecurringExpensesView()
                .tabItem {
                    Label("recurring".localized, systemImage: "repeat")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("settings".localized, systemImage: "gear")
                }
                .tag(4)
        }
        .tint(Color(.systemBlue))
    }
}

struct SettingsView: View {
    @ObservedObject private var dataManager = DataManager.shared

    @State private var showingMonthlySalary = false
    @State private var showingCurrencySelection = false
    @State private var showingDeletedExpenses = false
    @State private var showingDataExport = false
    @State private var showingDataImport = false
    @State private var showingAlert = false
    
    private var currentMonthSalaryText: String {
        let currentSalary = dataManager.getCurrentMonthSalary()
        return currentSalary > 0 ? formatCurrency(currentSalary, dataManager.user.currency) : "not_set".localized
    }
    
    private var currentMonthSalaryColor: Color {
        let currentSalary = dataManager.getCurrentMonthSalary()
        return currentSalary > 0 ? .secondary : .orange
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("profile".localized) {
                    Button(action: {
                        showingMonthlySalary = true
                    }) {
                        HStack {
                            Label("monthly_salaries".localized, systemImage: "calendar.badge.plus")
                                .foregroundStyle(Color(.systemBlue))
                            
                            Spacer()
                            
                            Text(currentMonthSalaryText)
                                .fontWeight(.medium)
                                .foregroundStyle(currentMonthSalaryColor)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        showingCurrencySelection = true
                    }) {
                        HStack {
                            Label("currency".localized, systemImage: "creditcard.fill")
                                .foregroundStyle(Color(.systemBlue))
                            
                            Spacer()
                            
                            Text(dataManager.user.currency.rawValue)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                
                Section("statistics".localized) {
                    StatRowView(
                        title: "total_expenses".localized,
                        value: formatCurrency(dataManager.getTotalExpenses(), dataManager.user.currency),
                        icon: "chart.bar.fill",
                        color: Color(.systemRed)
                    )
                    
                    StatRowView(
                        title: "remaining_budget".localized,
                        value: formatCurrency(dataManager.getRemainingBudget(), dataManager.user.currency),
                        icon: "banknote.fill",
                        color: Color(.systemGreen)
                    )
                }
                
                Section("data_management".localized) {
                    Button(action: {
                        showingDataImport = true
                    }) {
                        HStack {
                            Label("import_data".localized, systemImage: "square.and.arrow.down")
                                .foregroundStyle(Color(.systemBlue))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        showingDataExport = true
                    }) {
                        HStack {
                            Label("export_data".localized, systemImage: "square.and.arrow.up")
                                .foregroundStyle(Color(.systemGreen))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        showingDeletedExpenses = true
                    }) {
                        HStack {
                            Label("deleted_expenses".localized, systemImage: "trash.fill")
                                .foregroundStyle(Color(.systemBlue))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        showingAlert = true
                    }) {
                        Label("clear_all_data".localized, systemImage: "trash.fill")
                            .foregroundStyle(Color(.systemRed))
                    }
                    .buttonStyle(.plain)
                }
                
                Section("features".localized) {
                    NavigationLink(destination: BudgetSettingsView()) {
                        Label("budget_goals".localized, systemImage: "target")
                            .foregroundStyle(Color(.systemGreen))
                    }
                    NavigationLink(destination: CategoryManagementView()) {
                        Label("categories".localized, systemImage: "tag")
                            .foregroundStyle(Color(.systemOrange))
                    }
                }
                
                Section("about".localized) {
                    HStack {
                        Label("smartspend".localized + " v2.0", systemImage: "info.circle.fill")
                            .foregroundStyle(Color(.systemBlue))
                        Spacer()
                    }
                    
                    HStack {
                        Label("smart_learning".localized, systemImage: "brain.head.profile")
                            .foregroundStyle(Color(.systemPurple))
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color(.systemGreen))
                    }
                }
            }
            .navigationTitle("settings".localized)
            .navigationBarTitleDisplayMode(.large)

            .sheet(isPresented: $showingMonthlySalary) {
                MonthlySalaryView()
            }
            .sheet(isPresented: $showingCurrencySelection) {
                CurrencySelectionView()
            }
            .sheet(isPresented: $showingDeletedExpenses) {
                DeletedExpensesView()
            }
            .sheet(isPresented: $showingDataExport) {
                DataExportView()
            }
            .sheet(isPresented: $showingDataImport) {
                DataImportView()
            }
            .alert("clear_all_data".localized, isPresented: $showingAlert) {
                Button("cancel".localized, role: .cancel) { }
                Button("delete".localized, role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("clear_all_data_message".localized)
            }
        }
    }
    
    private func clearAllData() {
        dataManager.expenses.removeAll()
        dataManager.learnedPatterns.removeAll()
        dataManager.monthlySalaries.removeAll()
        
        // Save the cleared data
        if let encoded = try? JSONEncoder().encode([Expense]()) {
            UserDefaults.standard.set(encoded, forKey: "expenses")
        }
        if let encoded = try? JSONEncoder().encode([LearnedPattern]()) {
            UserDefaults.standard.set(encoded, forKey: "learnedPatterns")
        }
        if let encoded = try? JSONEncoder().encode(User()) {
            UserDefaults.standard.set(encoded, forKey: "user")
        }
        if let encoded = try? JSONEncoder().encode([MonthlySalary]()) {
            UserDefaults.standard.set(encoded, forKey: "monthlySalaries")
        }
    }
    
    private func formatCurrency(_ amount: Double, _ currency: Currency) -> String {
        return CurrencyFormatter.format(amount, currency: currency)
    }
}

struct StatRowView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.15), in: Circle())
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MainTabView()
}
