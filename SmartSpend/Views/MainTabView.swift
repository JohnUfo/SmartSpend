import SwiftUI

struct MainTabView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var tabManager = TabManager.shared
    
    var body: some View {
        TabView(selection: $tabManager.selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            ExpenseListView()
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet.rectangle")
                }
                .tag(1)
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            RecurringExpensesView()
                .tabItem {
                    Label("Recurring", systemImage: "repeat")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
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
        return currentSalary > 0 ? formatCurrency(currentSalary, dataManager.user.currency) : "Not Set"
    }
    
    private var currentMonthSalaryColor: Color {
        let currentSalary = dataManager.getCurrentMonthSalary()
        return currentSalary > 0 ? .secondary : .orange
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    Button(action: {
                        showingMonthlySalary = true
                    }) {
                        HStack {
                            Label("Monthly Salaries", systemImage: "calendar.badge.plus")
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
                            Label("Currency", systemImage: "creditcard.fill")
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
                
                Section("Statistics") {
                    StatRowView(
                        title: "Total Expenses",
                        value: formatCurrency(dataManager.getTotalExpenses(), dataManager.user.currency),
                        icon: "chart.bar.fill",
                        color: Color(.systemRed)
                    )
                    
                    StatRowView(
                        title: "Remaining Budget",
                        value: formatCurrency(dataManager.getRemainingBudget(), dataManager.user.currency),
                        icon: "banknote.fill",
                        color: Color(.systemGreen)
                    )
                    
                    StatRowView(
                        title: "Categories Used",
                        value: "\(dataManager.getExpensesByCategory().count)",
                        icon: "tag.fill",
                        color: Color(.systemOrange)
                    )
                }
                
                Section("Data Management") {
                    Button(action: {
                        showingDataImport = true
                    }) {
                        HStack {
                            Label("Import Data", systemImage: "square.and.arrow.down")
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
                            Label("Export Data", systemImage: "square.and.arrow.up")
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
                            Label("Deleted Expenses", systemImage: "trash.fill")
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
                        Label("Clear All Data", systemImage: "trash.fill")
                            .foregroundStyle(Color(.systemRed))
                    }
                    .buttonStyle(.plain)
                }
                
                Section("Features") {
                    NavigationLink(destination: BudgetSettingsView()) {
                        HStack {
                            Label("Budget & Goals", systemImage: "target")
                                .foregroundStyle(Color(.systemGreen))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                
                Section("About") {
                    HStack {
                        Label("SmartSpend v2.0", systemImage: "info.circle.fill")
                            .foregroundStyle(Color(.systemBlue))
                        Spacer()
                    }
                    
                    HStack {
                        Label("Smart Learning", systemImage: "brain.head.profile")
                            .foregroundStyle(Color(.systemPurple))
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color(.systemGreen))
                    }
                }
            }
            .navigationTitle("Settings")
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
            .alert("Clear All Data", isPresented: $showingAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all your expenses and learned patterns. This action cannot be undone.")
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
