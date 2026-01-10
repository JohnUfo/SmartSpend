import SwiftUI

struct RecurringExpensesView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingAddRecurring = false
    @State private var selectedRecurring: RecurringExpense?
    @State private var isSelectionMode = false
    @State private var selectedRecurringExpenses: Set<UUID> = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Notifications Section
                if !dataManager.getRecurringExpenseNotifications().isEmpty {
                    NotificationsSection(notifications: dataManager.getRecurringExpenseNotifications())
                }
                
                // Recurring Expenses List
                if dataManager.recurringExpenses.isEmpty {
                    EmptyRecurringExpensesView()
                } else {
                    List {
                        ForEach(dataManager.recurringExpenses) { recurring in
                            RecurringExpenseRowView(
                                recurringExpense: recurring,
                                isSelectionMode: $isSelectionMode,
                                selectedRecurringExpenses: $selectedRecurringExpenses
                            )
                            .onTapGesture {
                                if isSelectionMode {
                                    toggleSelection(recurring)
                                } else {
                                    selectedRecurring = recurring
                                }
                            }
                        }
                        .onDelete(perform: deleteRecurringExpenses)
                    }
                    .listStyle(.insetGrouped)
                }
                
                Spacer(minLength: 0)
            }
            .navigationTitle("recurring_expenses_title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingToolbarContent
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingToolbarContent
                }
            }
            .sheet(isPresented: $showingAddRecurring) {
                AddRecurringExpenseView()
            }
            .sheet(item: $selectedRecurring) { recurring in
                EditRecurringExpenseView(recurringExpense: recurring)
            }
            .overlay(alignment: .bottom) {
                selectionInfoBar
            }
            .onAppear {
                dataManager.processRecurringExpenses()
            }
        }
    }
    
    // MARK: - Toolbar Content
    
    @ViewBuilder
    private var leadingToolbarContent: some View {
        if isSelectionMode {
            Button("Cancel") {
                withAnimation {
                    isSelectionMode = false
                    selectedRecurringExpenses.removeAll()
                }
            }
        }
    }
    
    @ViewBuilder
    private var trailingToolbarContent: some View {
        if isSelectionMode {
            Button(action: deleteSelectedRecurring) {
                Image(systemName: "trash")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(selectedRecurringExpenses.isEmpty ? Color.secondary : Color.red)
            }
            .disabled(selectedRecurringExpenses.isEmpty)
        } else {
            HStack(spacing: 16) {
                if !dataManager.recurringExpenses.isEmpty {
                    Button(action: {
                        withAnimation {
                            isSelectionMode = true
                        }
                    }) {
                        Image(systemName: "checkmark.circle")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.blue)
                    }
                }
                
                Button(action: { showingAddRecurring = true }) {
                    Image(systemName: "plus")
                        .font(.title3)
                        .foregroundStyle(.tint)
                }
            }
        }
    }
    
    // MARK: - Selection Info Bar
    
    @ViewBuilder
    private var selectionInfoBar: some View {
        if isSelectionMode && !selectedRecurringExpenses.isEmpty {
            HStack {
                Text("\(selectedRecurringExpenses.count) selected")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: selectAllRecurring) {
                    Text("Select All")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.regularMaterial)
        }
    }
    
    // MARK: - Actions
    
    private func toggleSelection(_ recurring: RecurringExpense) {
        if selectedRecurringExpenses.contains(recurring.id) {
            selectedRecurringExpenses.remove(recurring.id)
        } else {
            selectedRecurringExpenses.insert(recurring.id)
        }
    }
    
    private func selectAllRecurring() {
        selectedRecurringExpenses = Set(dataManager.recurringExpenses.map { $0.id })
    }
    
    private func deleteSelectedRecurring() {
        withAnimation {
            for recurringId in selectedRecurringExpenses {
                if let recurring = dataManager.recurringExpenses.first(where: { $0.id == recurringId }) {
                    dataManager.deleteRecurringExpense(recurring)
                }
            }
            selectedRecurringExpenses.removeAll()
            isSelectionMode = false
        }
    }
    
    private func deleteRecurringExpenses(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                dataManager.deleteRecurringExpense(dataManager.recurringExpenses[index])
            }
        }
    }
}

// MARK: - Notifications Section
struct NotificationsSection: View {
    let notifications: [RecurringExpenseNotification]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(notifications) { notification in
                HStack {
                    Image(systemName: notification.type.icon)
                        .foregroundColor(colorForType(notification.type))
                        .frame(width: 20)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(notification.type.title)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(colorForType(notification.type))
                        
                        Text(notification.message)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button("process".localized) {
                        DataManager.shared.processRecurringExpenses()
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(colorForType(notification.type).opacity(0.1))
                    .foregroundColor(colorForType(notification.type))
                    .cornerRadius(6)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(colorForType(notification.type).opacity(0.05))
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
    }
    
    private func colorForType(_ type: RecurringExpenseNotification.NotificationType) -> Color {
        switch type {
        case .due:
            return .blue
        case .overdue:
            return .red
        case .upcoming:
            return .orange
        }
    }
}

// MARK: - Empty State
struct EmptyRecurringExpensesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "repeat.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(.tertiary)
                
                VStack(spacing: 8) {
                    Text("no_recurring_expenses".localized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text("set_up_recurring_expenses".localized)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Recurring Expense Row
struct RecurringExpenseRowView: View {
    let recurringExpense: RecurringExpense
    @Binding var isSelectionMode: Bool
    @Binding var selectedRecurringExpenses: Set<UUID>
    @ObservedObject private var dataManager = DataManager.shared
    
    private var isSelected: Bool {
        selectedRecurringExpenses.contains(recurringExpense.id)
    }
    
    // Resolve user category if present
    private var categoryDisplayInfo: (name: String, icon: String, color: Color) {
        if let userCategoryId = recurringExpense.userCategoryId,
           let userCategory = dataManager.userCategories.first(where: { $0.id == userCategoryId }) {
            return (userCategory.name, userCategory.iconSystemName, userCategory.color)
        }
        return (recurringExpense.category.localizedName, recurringExpense.category.icon, recurringExpense.category.color)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection Checkbox
            if isSelectionMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.blue : Color.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Category Icon
                    Image(systemName: categoryDisplayInfo.icon)
                        .font(.title3)
                        .foregroundColor(categoryDisplayInfo.color)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(recurringExpense.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(categoryDisplayInfo.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(CurrencyFormatter.format(recurringExpense.amount, currency: dataManager.user.currency))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: recurringExpense.recurrenceType.icon)
                                .font(.caption2)
                            Text(recurringExpense.recurrenceType.rawValue)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                // Status and Next Due
                HStack {
                    // Status Badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                        
                        Text(statusText)
                            .font(.caption2)
                            .foregroundColor(statusColor)
                    }
                    
                    Spacer()
                    
                    // Next Due Date
                    Text("\("next".localized): \(DateFormatter.shortDate.string(from: recurringExpense.nextDueDate))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
    
    private var statusColor: Color {
        if !recurringExpense.isActive {
            return .gray
        } else if recurringExpense.isExpired {
            return .gray
        } else if recurringExpense.isOverdue {
            return .red
        } else if recurringExpense.isDue {
            return .orange
        } else {
            return .green
        }
    }
    
    private var statusText: String {
        if !recurringExpense.isActive {
            return "inactive".localized
        } else if recurringExpense.isExpired {
            return "expired".localized
        } else if recurringExpense.isOverdue {
            return "overdue".localized
        } else if recurringExpense.isDue {
            return "due".localized
        } else {
            return "active".localized
        }
    }
}

// Note: DateFormatter.shortDate is already defined in AnalyticsView.swift

#Preview {
    RecurringExpensesView()
}
