import SwiftUI

struct AddRecurringExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory: ExpenseCategory = .food
    @State private var selectedRecurrence: RecurrenceType = .monthly
    @State private var startDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var isActive = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Expense Details") {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(Color(category.color))
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section("Recurrence") {
                    Picker("Frequency", selection: $selectedRecurrence) {
                        ForEach(RecurrenceType.allCases, id: \.self) { recurrence in
                            HStack {
                                Image(systemName: recurrence.icon)
                                Text(recurrence.rawValue)
                            }
                            .tag(recurrence)
                        }
                    }
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Toggle("End Date", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    }
                }
                
                Section("Settings") {
                    Toggle("Active", isOn: $isActive)
                }
                
                Section {
                    RecurrencePreviewView(
                        recurrenceType: selectedRecurrence,
                        startDate: startDate,
                        endDate: hasEndDate ? endDate : nil
                    )
                }
            }
            .navigationTitle("Add Recurring Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveRecurringExpense()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !amount.isEmpty &&
        Double(amount) != nil &&
        Double(amount)! > 0
    }
    
    private func saveRecurringExpense() {
        guard let amountValue = Double(amount) else { return }
        
        let recurringExpense = RecurringExpense(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amountValue,
            category: selectedCategory,
            recurrenceType: selectedRecurrence,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil
        )
        
        var newRecurring = recurringExpense
        newRecurring.isActive = isActive
        
        dataManager.addRecurringExpense(newRecurring)
        dismiss()
    }
}

struct EditRecurringExpenseView: View {
    let recurringExpense: RecurringExpense
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory: ExpenseCategory = .food
    @State private var selectedRecurrence: RecurrenceType = .monthly
    @State private var startDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Date()
    @State private var isActive = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Expense Details") {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(Color(category.color))
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                }
                
                Section("Recurrence") {
                    Picker("Frequency", selection: $selectedRecurrence) {
                        ForEach(RecurrenceType.allCases, id: \.self) { recurrence in
                            HStack {
                                Image(systemName: recurrence.icon)
                                Text(recurrence.rawValue)
                            }
                            .tag(recurrence)
                        }
                    }
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Toggle("End Date", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    }
                }
                
                Section("Settings") {
                    Toggle("Active", isOn: $isActive)
                }
                
                Section("Status") {
                    if let lastProcessed = recurringExpense.lastProcessedDate {
                        HStack {
                            Text("Last Processed")
                            Spacer()
                            Text(DateFormatter.shortDate.string(from: lastProcessed))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("Next Due")
                        Spacer()
                        Text(DateFormatter.shortDate.string(from: recurringExpense.nextDueDate))
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    RecurrencePreviewView(
                        recurrenceType: selectedRecurrence,
                        startDate: startDate,
                        endDate: hasEndDate ? endDate : nil
                    )
                }
            }
            .navigationTitle("Edit Recurring Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                loadExpenseData()
            }
        }
    }
    
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !amount.isEmpty &&
        Double(amount) != nil &&
        Double(amount)! > 0
    }
    
    private func loadExpenseData() {
        title = recurringExpense.title
        amount = String(format: "%.2f", recurringExpense.amount)
        selectedCategory = recurringExpense.category
        selectedRecurrence = recurringExpense.recurrenceType
        startDate = recurringExpense.startDate
        hasEndDate = recurringExpense.endDate != nil
        endDate = recurringExpense.endDate ?? Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        isActive = recurringExpense.isActive
    }
    
    private func saveChanges() {
        guard let amountValue = Double(amount) else { return }
        
        var updatedExpense = recurringExpense
        updatedExpense.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedExpense.amount = amountValue
        updatedExpense.category = selectedCategory
        updatedExpense.recurrenceType = selectedRecurrence
        updatedExpense.startDate = startDate
        updatedExpense.endDate = hasEndDate ? endDate : nil
        updatedExpense.isActive = isActive
        
        dataManager.updateRecurringExpense(updatedExpense)
        dismiss()
    }
}

// MARK: - Recurrence Preview
struct RecurrencePreviewView: View {
    let recurrenceType: RecurrenceType
    let startDate: Date
    let endDate: Date?
    
    private var upcomingDates: [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        
        for _ in 0..<5 {
            dates.append(currentDate)
            currentDate = recurrenceType.nextDate(from: currentDate)
            
            if let end = endDate, currentDate > end {
                break
            }
        }
        
        return dates
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Upcoming Occurrences")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(upcomingDates.indices, id: \.self) { index in
                    HStack {
                        Text("\(index + 1).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 20, alignment: .leading)
                        
                        Text(DateFormatter.mediumDate.string(from: upcomingDates[index]))
                            .font(.caption)
                            .foregroundColor(.primary)
                        
                        if index == 0 {
                            Text("(Start)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                
                if upcomingDates.count == 5 {
                    Text("...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

#Preview {
    AddRecurringExpenseView()
}
