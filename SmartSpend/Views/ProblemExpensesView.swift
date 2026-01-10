import SwiftUI

struct ProblemExpensesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    
    @State private var selectedExpense: Expense?
    @State private var showingEditSheet = false
    @State private var showingApplyToAllAlert = false
    @State private var lastEditedExpense: Expense?
    
    // Get expenses that need attention (category is "other" AND no user category assigned)
    private var problemExpenses: [Expense] {
        let filtered = dataManager.expenses.filter { expense in
            // Filter expenses with "other" category that haven't been assigned a user category
            expense.category == .other && expense.userCategoryId == nil
        }
        let sorted = filtered.sorted { $0.date > $1.date }
        return sorted
    }
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("problem_expenses_title".localized)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        toolbarMenu
                    }
                }
                .sheet(item: $selectedExpense) { expense in
                    EditExpenseView(expense: expense)
                }
                .alert("apply_category_to_all_title".localized, isPresented: $showingApplyToAllAlert) {
                    Button("apply_to_all".localized) {
                        applyToAllWithSameTitle()
                    }
                    Button("just_this_one".localized, role: .cancel) { }
                } message: {
                    alertMessage
                }
                .onChange(of: dataManager.expenses) { oldValue, newValue in
                    checkForRecentEdit(oldValue: oldValue, newValue: newValue)
                }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if problemExpenses.isEmpty {
            emptyStateView
        } else {
            expensesList
        }
    }
    
    private var expensesList: some View {
        List {
            Section {
                Text("problem_expenses_description".localized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }
            
            Section {
                ForEach(problemExpenses) { expense in
                    ProblemExpenseRow(expense: expense)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedExpense = expense
                            showingEditSheet = true
                        }
                }
            } header: {
                sectionHeader
            }
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text("expenses_needing_review".localized)
            Spacer()
            Text("\(problemExpenses.count)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(.orange, in: Capsule())
        }
    }
    
    @ViewBuilder
    private var toolbarMenu: some View {
        if !problemExpenses.isEmpty {
            Menu {
                Button {
                    fixAllAutomatically()
                } label: {
                    Label("auto_categorize_all".localized, systemImage: "wand.and.stars")
                }
                
                Button(role: .destructive) {
                    deleteAllProblemExpenses()
                } label: {
                    Label("delete_all".localized, systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
    
    @ViewBuilder
    private var alertMessage: some View {
        if let expense = lastEditedExpense {
            Text(String(format: "apply_category_to_all_message".localized, expense.title))
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
            
            Text("no_problem_expenses_title".localized)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("no_problem_expenses_message".localized)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func fixAllAutomatically() {
        // This would use the smart learning to suggest categories
        // For now, we'll keep them as-is since you said not to auto-correct
    }
    
    private func deleteAllProblemExpenses() {
        for expense in problemExpenses {
            dataManager.deleteExpense(expense)
        }
    }
    
    private func checkForRecentEdit(oldValue: [Expense], newValue: [Expense]) {
        // Find if an expense was just updated (same ID but different userCategoryId)
        for newExpense in newValue {
            if let oldExpense = oldValue.first(where: { $0.id == newExpense.id }) {
                // Check if user category was just assigned (changed from nil to some value)
                if oldExpense.userCategoryId == nil && newExpense.userCategoryId != nil {
                    // Check if there are other expenses with the same title that need categorization
                    let similarExpenses = dataManager.expenses.filter { 
                        $0.title.lowercased().trimmingCharacters(in: .whitespaces) == newExpense.title.lowercased().trimmingCharacters(in: .whitespaces) && 
                        $0.id != newExpense.id &&
                        $0.userCategoryId == nil &&
                        $0.category == .other
                    }
                    
                    if !similarExpenses.isEmpty {
                        lastEditedExpense = newExpense
                        showingApplyToAllAlert = true
                    }
                }
            }
        }
    }
    
    private func applyToAllWithSameTitle() {
        guard let edited = lastEditedExpense else { return }
        
        // Find all expenses with the same title that need categorization
        for (index, expense) in dataManager.expenses.enumerated() {
            if expense.title.lowercased().trimmingCharacters(in: .whitespaces) == edited.title.lowercased().trimmingCharacters(in: .whitespaces) &&
               expense.id != edited.id &&
               expense.userCategoryId == nil &&
               expense.category == .other {
                var updatedExpense = expense
                updatedExpense.userCategoryId = edited.userCategoryId
                dataManager.expenses[index] = updatedExpense
            }
        }
        
        // Clear the last edited expense
        lastEditedExpense = nil
    }
}

struct ProblemExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        HStack(spacing: 12) {
            // Warning icon
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title3)
                .foregroundStyle(.orange)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(.orange.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 8) {
                    Image(systemName: expense.category.icon)
                        .font(.caption2)
                        .foregroundStyle(expense.category.color)
                    
                    Text(expense.category.rawValue.localized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    
                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(CurrencyFormatter.format(expense.amount, currency: DataManager.shared.user.currency))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
                
                Text("needs_review".localized)
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProblemExpensesView()
}
