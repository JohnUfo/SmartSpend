import SwiftUI

struct BudgetSettingsView: View {
    @ObservedObject private var dataManager = DataManager.shared
    
    var body: some View {
        List {
            Section {
                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                    BudgetRow(category: category)
                }
            } header: {
                Text("monthly_budgets".localized)
            } footer: {
                Text("total_monthly_budget".localized + ": " + CurrencyFormatter.format(dataManager.getTotalBudget(), currency: dataManager.user.currency))
            }
        }
        .navigationTitle("budget_goals".localized)
    }
}

struct BudgetRow: View {
    let category: ExpenseCategory
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingEditSheet = false
    
    var body: some View {
        Button(action: {
            showingEditSheet = true
        }) {
            HStack {
                Label {
                    Text(category.rawValue.localized)
                        .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: category.icon)
                        .foregroundStyle(category.color)
                }
                
                Spacer()
                
                let budget = dataManager.getBudget(for: category)
                if budget > 0 {
                    Text(CurrencyFormatter.format(budget, currency: dataManager.user.currency))
                        .foregroundStyle(.primary)
                } else {
                    Text("not_set".localized)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditBudgetView(category: category)
        }
    }
}

struct EditBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    let category: ExpenseCategory
    @ObservedObject private var dataManager = DataManager.shared
    @State private var amountString = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text(dataManager.user.currency.rawValue)
                        TextField("amount".localized, text: $amountString)
                            .keyboardType(.decimalPad)
                    }
                } footer: {
                    Text("enter_0_to_remove".localized)
                }
            }
            .navigationTitle(category.rawValue.localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("save".localized) {
                        save()
                    }
                }
            }
            .onAppear {
                let currentBudget = dataManager.getBudget(for: category)
                if currentBudget > 0 {
                    amountString = String(format: "%.2f", currentBudget)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func save() {
        if let amount = Double(amountString) {
            dataManager.setBudget(for: category, amount: amount)
        }
        dismiss()
    }
}

#Preview {
    BudgetSettingsView()
}

