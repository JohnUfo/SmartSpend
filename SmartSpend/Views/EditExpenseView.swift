import SwiftUI

struct EditExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    
    let expense: Expense
    
    @State private var title: String
    @State private var amount: String
    @State private var selectedCategory: ExpenseCategory
    @State private var selectedDate: Date
    
    init(expense: Expense) {
        self.expense = expense
        self._title = State(initialValue: expense.title)
        self._amount = State(initialValue: String(format: "%.2f", expense.amount))
        self._selectedCategory = State(initialValue: expense.category)
        self._selectedDate = State(initialValue: expense.date)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Title Field
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Expense title", text: $title, axis: .vertical)
                            .textFieldStyle(.plain)
                    }
                    
                    // Amount Field
                    HStack {
                        Text(dataManager.user.currency.symbol)
                            .foregroundStyle(.secondary)
                            .font(.body)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.plain)
                    }
                    
                    // Category Picker
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .foregroundStyle(category.color)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // Date Picker
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                } header: {
                    Text("Expense Details")
                } footer: {
                    Text("Update your expense details.")
                        .font(.caption)
                }
            }
            .navigationTitle("Edit Expense")
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
                        updateExpense()
                    }
                    .disabled(title.isEmpty || amount.isEmpty || Double(amount) == nil)
                    .fontWeight(.semibold)
                    .foregroundStyle(title.isEmpty || amount.isEmpty || Double(amount) == nil ? Color.secondary : Color.accentColor)
                }
            }
        }
    }
    
    private func updateExpense() {
        guard let amountValue = Double(amount), !title.isEmpty else { return }
        
        let updatedExpense = Expense(
            title: title,
            amount: amountValue,
            category: selectedCategory,
            date: selectedDate
        )
        
        // Find and update the expense
        if let index = dataManager.expenses.firstIndex(where: { $0.id == expense.id }) {
            dataManager.expenses[index] = updatedExpense
        }
        
        dismiss()
    }
}

#Preview {
    EditExpenseView(expense: Expense(
        title: "Coffee",
        amount: 4.50,
        category: .food,
        date: Date()
    ))
}
