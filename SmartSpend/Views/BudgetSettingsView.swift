import SwiftUI

struct BudgetSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingAddGoal = false
    
    private var canSuggestBudgets: Bool {
        // Allow suggestions if we have at least 10 expenses
        return dataManager.expenses.count >= 10
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Category Budgets Section
                Section {
                    ForEach([ExpenseCategory.food, .transportation, .shopping, .bills, .entertainment, .other], id: \.self) { category in
                        CategoryBudgetSettingRow(category: category)
                    }
                } header: {
                    Text("Monthly Category Budgets")
                } footer: {
                    Text("Set monthly spending limits for each category. You'll receive notifications when approaching these limits.")
                        .font(.caption)
                }
                
                // Spending Goals Section
                Section {
                    ForEach(dataManager.spendingGoals) { goal in
                        SpendingGoalRow(goal: goal)
                    }
                    .onDelete(perform: deleteGoal)
                    
                    Button(action: { showingAddGoal = true }) {
                        Label("Add Spending Goal", systemImage: "plus.circle")
                            .foregroundStyle(.tint)
                    }
                } header: {
                    Text("Spending Goals")
                } footer: {
                    Text("Set savings targets and track your progress toward financial goals.")
                        .font(.caption)
                }
                
                // Quick Actions Section
                Section("Quick Actions") {
                    Button(action: resetAllBudgets) {
                        Label("Reset All Budgets", systemImage: "arrow.counterclockwise")
                            .foregroundStyle(.orange)
                    }
                    
                    Button(action: suggestBudgets) {
                        Label("Suggest Budgets", systemImage: "sparkles")
                            .foregroundStyle(canSuggestBudgets ? .blue : .gray)
                    }
                    .disabled(!canSuggestBudgets)
                    .onAppear {
                        // Check requirements when view appears
                    }
                }
            }
            .navigationTitle("Budget Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.tint)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dataManager.saveBudgets()
                        dismiss()
                    }
                    .foregroundStyle(.tint)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddSpendingGoalView()
            }
            .onAppear {
                dataManager.updateSpendingGoalProgress()
            }
        }
    }
    
    private func deleteGoal(at offsets: IndexSet) {
        dataManager.spendingGoals.remove(atOffsets: offsets)
        dataManager.saveSpendingGoals()
    }
    
    private func resetAllBudgets() {
        for i in 0..<dataManager.categoryBudgets.count {
            dataManager.categoryBudgets[i].amount = 0
            dataManager.categoryBudgets[i].isEnabled = false
        }
        dataManager.saveBudgets()
        
        // Force UI refresh by triggering objectWillChange
        dataManager.objectWillChange.send()
    }
    
    private func suggestBudgets() {
        let calendar = Calendar.current
        let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        
        // Use last 3 months of data, or all available data if less than 3 months
        let availableExpenses = dataManager.expenses.filter { expense in
            expense.date >= threeMonthsAgo
        }
        
        // If we don't have 3 months of data, use all available data
        let expensesToUse = availableExpenses.isEmpty ? dataManager.expenses : availableExpenses
        let monthsOfData = max(1, Double(expensesToUse.count) / 30.0) // Rough estimate
        
        for category in ExpenseCategory.allCases {
            let categoryExpenses = expensesToUse.filter { expense in
                expense.category == category
            }
            
            if !categoryExpenses.isEmpty {
                let totalSpending = categoryExpenses.reduce(0) { $0 + $1.amount }
                let avgMonthlySpending = totalSpending / monthsOfData
                let suggestedBudget = avgMonthlySpending * 1.1 // 10% buffer
                
                if let index = dataManager.categoryBudgets.firstIndex(where: { $0.category == category }) {
                    dataManager.categoryBudgets[index].amount = suggestedBudget
                    dataManager.categoryBudgets[index].isEnabled = suggestedBudget > 0
                } else {
                    // Create new budget if it doesn't exist
                    let newBudget = CategoryBudget(category: category, amount: suggestedBudget, isEnabled: suggestedBudget > 0)
                    dataManager.categoryBudgets.append(newBudget)
                }
            }
        }
        
        // Save the suggested budgets immediately and trigger UI update
        dataManager.saveBudgets()
        
        // Force UI refresh by triggering objectWillChange
        dataManager.objectWillChange.send()
    }
}

struct CategoryBudgetSettingRow: View {
    let category: ExpenseCategory
    @ObservedObject private var dataManager = DataManager.shared
    @State private var budgetAmount: String = ""
    @State private var isEnabled: Bool = false
    
    private var budget: CategoryBudget? {
        dataManager.categoryBudgets.first { $0.category == category }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(category.rawValue, systemImage: category.icon)
                    .foregroundStyle(category.color)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
            }
            
            if isEnabled {
                HStack {
                    Text(dataManager.user.currency.symbol)
                        .foregroundStyle(.secondary)
                    
                    TextField("0.00", text: $budgetAmount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.plain)
                        .onChange(of: budgetAmount) { _, newValue in
                            updateBudget()
                        }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .onAppear {
            updateLocalState()
        }
        .onChange(of: isEnabled) { _, newValue in
            updateBudget()
        }
        .onChange(of: dataManager.categoryBudgets) { _, _ in
            updateLocalState()
        }
    }
    
    private func updateBudget() {
        let amount = Double(budgetAmount) ?? 0
        
        if let index = dataManager.categoryBudgets.firstIndex(where: { $0.category == category }) {
            dataManager.categoryBudgets[index].amount = amount
            dataManager.categoryBudgets[index].isEnabled = isEnabled && amount > 0
        } else {
            let newBudget = CategoryBudget(category: category, amount: amount, isEnabled: isEnabled && amount > 0)
            dataManager.categoryBudgets.append(newBudget)
        }
    }
    
    private func updateLocalState() {
        if let budget = budget {
            budgetAmount = budget.amount > 0 ? String(format: "%.2f", budget.amount) : ""
            isEnabled = budget.isEnabled
        } else {
            budgetAmount = ""
            isEnabled = false
        }
    }
}

struct SpendingGoalRow: View {
    let goal: SpendingGoal
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingCompletionAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                }
            }
            
            HStack {
                Text("Target: \(CurrencyFormatter.format(goal.targetAmount, currency: dataManager.user.currency))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("Due: \(goal.deadline, style: .date)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            HStack {
                Text("Saved: \(CurrencyFormatter.format(goal.currentAmount, currency: dataManager.user.currency))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(Int(goal.progress * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(goal.isCompleted ? .green : .blue)
            }
            
            ProgressView(value: goal.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: goal.isCompleted ? .green : .blue))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
        }
        .padding(.vertical, 4)
        .onChange(of: goal.progress) { _, newProgress in
            if newProgress >= 1.0 && !goal.isCompleted {
                showingCompletionAlert = true
            }
        }
        .alert("Goal Completed! 🎉", isPresented: $showingCompletionAlert) {
            Button("OK") { }
        } message: {
            Text("Congratulations! You've reached your goal: \(goal.title)")
        }
    }
}

struct AddSpendingGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    
    @State private var title = ""
    @State private var targetAmount = ""
    @State private var deadline = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days from now
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Goal title", text: $title)
                        .textInputAutocapitalization(.words)
                    
                    HStack {
                        Text(dataManager.user.currency.symbol)
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $targetAmount)
                            .keyboardType(.decimalPad)
                    }
                    
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                } header: {
                    Text("Goal Details")
                } footer: {
                    Text("Set a savings goal with a target amount and deadline.")
                        .font(.caption)
                }
            }
            .navigationTitle("New Spending Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.tint)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(title.isEmpty || targetAmount.isEmpty || Double(targetAmount) == nil)
                    .foregroundStyle(.tint)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveGoal() {
        guard let amount = Double(targetAmount), amount > 0 else { return }
        
        let goal = SpendingGoal(title: title, targetAmount: amount, deadline: deadline)
        dataManager.spendingGoals.append(goal)
        dataManager.saveSpendingGoals()
        dismiss()
    }
}

#Preview {
    BudgetSettingsView()
}
