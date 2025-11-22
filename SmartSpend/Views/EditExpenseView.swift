import SwiftUI

struct EditExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    
    let expense: Expense
    
    @State private var title: String
    @State private var amount: String
    @State private var selectedCategory: ExpenseCategory
    @State private var selectedUserCategory: UserCategory? = nil
    @State private var selectedDate: Date
    @State private var showingCategoryManagement = false
    
    private let mainCategories: [ExpenseCategory] = [.food, .transportation, .shopping, .bills, .entertainment, .other]
    
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
                    
                    // Category Selection - Now matching AddExpenseView
                    HStack {
                        Text("Category")
                        Spacer()
                        Menu {
                            // Main Categories
                            ForEach(mainCategories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                    selectedUserCategory = nil
                                }) {
                                    Label {
                                        Text(category.localizedName)
                                    } icon: {
                                        Image(systemName: category.icon)
                                    }
                                }
                            }
                            
                            // User Custom Categories
                            ForEach(dataManager.userCategories) { userCategory in
                                Button(action: {
                                    selectedUserCategory = userCategory
                                }) {
                                    Label {
                                        Text(userCategory.name)
                                    } icon: {
                                        Image(systemName: userCategory.iconSystemName)
                                    }
                                }
                            }
                            
                            Divider()
                            
                            // Create New Category
                            Button(action: { showingCategoryManagement = true }) {
                                Label("Create New Category", systemImage: "plus.circle")
                            }
                        } label: {
                            HStack(spacing: 4) {
                                if let userCat = selectedUserCategory {
                                    Image(systemName: userCat.iconSystemName)
                                        .foregroundStyle(userCat.color)
                                    Text(userCat.name)
                                        .foregroundStyle(.primary)
                                } else {
                                    Image(systemName: selectedCategory.icon)
                                        .foregroundStyle(selectedCategory.color)
                                    Text(selectedCategory.localizedName)
                                        .foregroundStyle(.primary)
                                }
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
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
            .sheet(isPresented: $showingCategoryManagement) {
                CategoryManagementView()
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
