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
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .padding(.top, 8)
                        
                        Text("budgets".localized)
                            .font(.title2.bold())
                        
                        Text("Set monthly spending limits and track your financial goals to master your money.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        HStack(spacing: 12) {
                            Button(action: suggestBudgets) {
                                Label("Suggest", systemImage: "sparkles")
                                    .fontWeight(.medium)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!canSuggestBudgets)
                            
                            Button(action: resetAllBudgets) {
                                Label("Reset", systemImage: "arrow.counterclockwise")
                                    .fontWeight(.medium)
                            }
                            .buttonStyle(.bordered)
                            .foregroundStyle(.red)
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
                    
                    // Category Budgets Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Monthly Category Budgets")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        LazyVStack(spacing: 12) {
                            ForEach(dataManager.userCategories) { category in
                                CategoryBudgetSettingRow(category: category)
                            }
                        }
                    }
                    
                    // Spending Goals Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Spending Goals")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: { showingAddGoal = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                            }
                        }
                        
                        if dataManager.spendingGoals.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "target")
                                    .font(.largeTitle)
                                    .foregroundStyle(.tertiary)
                                Text("No goals set yet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Button("Add Your First Goal") {
                                    showingAddGoal = true
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                        } else {
                            VStack(spacing: 12) {
                                ForEach(dataManager.spendingGoals) { goal in
                                    SpendingGoalRow(goal: goal)
                                        .padding()
                                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Budget Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dataManager.saveBudgets()
                        dismiss()
                    }
                    .fontWeight(.bold)
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
        let now = Date()
        
        // Use last 2 months for trend detection
        guard let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: now) else { return }
        
        let recentExpenses = dataManager.expenses.filter { $0.date >= twoMonthsAgo }
        
        // Group by month to calculate average
        let groupedByMonth = Dictionary(grouping: recentExpenses) { exp in
            calendar.dateComponents([.year, .month], from: exp.date)
        }
        
        let monthCount = max(1, Double(groupedByMonth.count))
        
        for category in dataManager.userCategories {
            let catExpenses = recentExpenses.filter { $0.categoryId == category.id }
            
            if !catExpenses.isEmpty {
                let total = catExpenses.reduce(0) { $0 + $1.amount }
                let monthlyAvg = total / monthCount
                
                // Logic: Suggest a budget that is 90% of your average for essential, 
                // or 110% for flexible (safety net). We'll go with 105% as a general realistic goal.
                let suggested = (monthlyAvg * 1.05).rounded()
                
                if let index = dataManager.categoryBudgets.firstIndex(where: { $0.categoryId == category.id }) {
                    dataManager.categoryBudgets[index].amount = suggested
                    dataManager.categoryBudgets[index].isEnabled = true
                } else {
                    let newBudget = CategoryBudget(categoryId: category.id, amount: suggested, isEnabled: true)
                    dataManager.categoryBudgets.append(newBudget)
                }
            }
        }
        
        dataManager.saveBudgets()
        dataManager.objectWillChange.send()
        
        // Optional: Trigger a haptic feedback or simple alert to inform the user
    }
}

struct CategoryBudgetSettingRow: View {
    let category: UserCategory
    @ObservedObject private var dataManager = DataManager.shared
    @State private var budgetAmount: String = ""
    @State private var isEnabled: Bool = false
    
    private var budget: CategoryBudget? {
        dataManager.categoryBudgets.first { $0.categoryId == category.id }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon & Name
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: category.iconSystemName)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(category.color, in: RoundedRectangle(cornerRadius: 8))
                    
                    Text(category.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
            
            // Amount Input or Toggle
            if isEnabled {
                HStack(spacing: 4) {
                    Text(dataManager.user.currency.symbol)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    TextField("0", text: $budgetAmount)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .frame(width: 80)
                        .onChange(of: budgetAmount) { _, _ in updateBudget() }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.systemGray6), in: Capsule())
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            
            Toggle("", isOn: $isEnabled.animation(.spring()))
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .green))
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .onAppear { updateLocalState() }
        .onChange(of: isEnabled) { _, _ in updateBudget() }
        .onChange(of: dataManager.categoryBudgets) { _, _ in updateLocalState() }
    }
    
    private func updateBudget() {
        let amount = Double(budgetAmount) ?? 0
        if let index = dataManager.categoryBudgets.firstIndex(where: { $0.categoryId == category.id }) {
            dataManager.categoryBudgets[index].amount = amount
            dataManager.categoryBudgets[index].isEnabled = isEnabled
        } else {
            let newBudget = CategoryBudget(categoryId: category.id, amount: amount, isEnabled: isEnabled)
            dataManager.categoryBudgets.append(newBudget)
        }
    }
    
    private func updateLocalState() {
        if let budget = budget {
            budgetAmount = budget.amount > 0 ? String(format: "%.0f", budget.amount) : ""
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
    @State private var selectedCategory: UserCategory?
    
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
                    
                    DatePicker("Deadline", selection: $deadline, in: Date()..., displayedComponents: .date)
                    
                    Picker("Category", selection: $selectedCategory) {
                        Text("Select Category").tag(nil as UserCategory?)
                        ForEach(dataManager.userCategories) { category in
                            HStack {
                                Image(systemName: category.iconSystemName)
                                Text(category.name)
                            }
                            .tag(category as UserCategory?)
                        }
                    }
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
                    .disabled(title.isEmpty || targetAmount.isEmpty || Double(targetAmount) == nil || selectedCategory == nil)
                    .foregroundStyle(.tint)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if selectedCategory == nil {
                    selectedCategory = dataManager.userCategories.first
                }
            }
        }
    }
    
    private func saveGoal() {
        guard let amount = Double(targetAmount), 
              amount > 0,
              let categoryId = selectedCategory?.id else { return }
        
        let goal = SpendingGoal(
            title: title, 
            targetAmount: amount, 
            deadline: deadline, 
            categoryId: categoryId
        )
        dataManager.spendingGoals.append(goal)
        dataManager.saveSpendingGoals()
        dismiss()
    }
}

#Preview {
    BudgetSettingsView()
}
