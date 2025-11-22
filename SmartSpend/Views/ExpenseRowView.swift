import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingEditExpense = false
    @State private var isPressed = false
    @Binding var isSelectionMode: Bool
    @Binding var selectedExpenses: Set<UUID>
    
    private var isSelected: Bool {
        selectedExpenses.contains(expense.id)
    }
    
    var body: some View {
        Button(action: {
            if isSelectionMode {
                toggleSelection()
            } else {
                showingEditExpense = true
            }
        }) {
            HStack(spacing: 12) {
                // Selection Checkbox (shown in selection mode)
                if isSelectionMode {
                    ZStack {
                        Circle()
                            .stroke(isSelected ? expense.category.color : Color(.systemGray3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if isSelected {
                            Circle()
                                .fill(expense.category.color)
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 4)
                    .transition(.scale.combined(with: .opacity))
                }
                
                HStack(spacing: 0) {
                    // Category Color Bar
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(expense.category.color)
                        .frame(width: 4)
                        .padding(.vertical, 4)
                    
                    HStack(spacing: 12) {
                        // Category Icon
                        Image(systemName: expense.category.icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(expense.category.color)
                            .frame(width: 40, height: 40)
                        
                        // Expense Details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(expense.title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            
                            Text(formatDate(expense.date))
                                .font(.system(size: 13))
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer(minLength: 12)
                        
                        // Amount
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(formatCurrency(expense.amount, dataManager.user.currency))
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                            
                            Text(expense.category.localizedName)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                        }
                    }
                    .padding(.leading, 12)
                    .padding(.trailing, 16)
                    .padding(.vertical, 12)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isSelected ? expense.category.color : Color.clear, lineWidth: 2)
                )
            }
        }
        .buttonStyle(PressEffectButtonStyle())
        .listRowInsets(EdgeInsets(top: 5, leading: isSelectionMode ? 0 : 16, bottom: 5, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .contextMenu {
            Button(action: { showingEditExpense = true }) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: {
                withAnimation {
                    dataManager.moveToDeletedExpenses(expense)
                }
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingEditExpense) {
            EditExpenseView(expense: expense)
        }
    }
    
    private func toggleSelection() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if isSelected {
                selectedExpenses.remove(expense.id)
            } else {
                selectedExpenses.insert(expense.id)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: date)
        }
    }
    
    private func formatCurrency(_ amount: Double, _ currency: Currency) -> String {
        return CurrencyFormatter.format(amount, currency: currency)
    }
}

// MARK: - 3D Press Effect Button Style
struct PressEffectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ExpenseRowView(
        expense: Expense(
            title: "Coffee",
            amount: 4.50,
            category: .food,
            date: Date()
        ),
        isSelectionMode: .constant(false),
        selectedExpenses: .constant([])
    )
    .padding()
}
