import SwiftUI

struct RecurringExpensesView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingAddRecurring = false
    @State private var selectedRecurring: RecurringExpense?
    
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
                            RecurringExpenseRowView(recurringExpense: recurring)
                                .onTapGesture {
                                    selectedRecurring = recurring
                                }
                        }
                        .onDelete(perform: deleteRecurringExpenses)
                    }
                    .listStyle(.insetGrouped)
                }
                
                Spacer(minLength: 0)
            }
            .navigationTitle("Recurring Expenses")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecurring = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundStyle(.tint)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: processAllRecurring) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundStyle(.tint)
                    }
                }
            }
            .sheet(isPresented: $showingAddRecurring) {
                AddRecurringExpenseView()
            }
            .sheet(item: $selectedRecurring) { recurring in
                EditRecurringExpenseView(recurringExpense: recurring)
            }
            .onAppear {
                dataManager.processRecurringExpenses()
            }
        }
    }
    
    private func deleteRecurringExpenses(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                dataManager.deleteRecurringExpense(dataManager.recurringExpenses[index])
            }
        }
    }
    
    private func processAllRecurring() {
        dataManager.processRecurringExpenses()
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
                    
                    Button("Process") {
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
                    Text("No Recurring Expenses")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text("Set up recurring expenses like rent, subscriptions, or utilities to track them automatically.")
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
    @ObservedObject private var dataManager = DataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Category Icon
                Image(systemName: recurringExpense.category.icon)
                    .font(.title3)
                    .foregroundColor(Color(recurringExpense.category.color))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(recurringExpense.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(recurringExpense.category.rawValue)
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
                Text("Next: \(DateFormatter.shortDate.string(from: recurringExpense.nextDueDate))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
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
            return "Inactive"
        } else if recurringExpense.isExpired {
            return "Expired"
        } else if recurringExpense.isOverdue {
            return "Overdue"
        } else if recurringExpense.isDue {
            return "Due"
        } else {
            return "Active"
        }
    }
}

// Note: DateFormatter.shortDate is already defined in AnalyticsView.swift

#Preview {
    RecurringExpensesView()
}
