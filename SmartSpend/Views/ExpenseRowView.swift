import SwiftUI

struct ExpenseRowView: View {
    let expense: Expense
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var deleteManager = DeleteButtonManager.shared
    @State private var showingEditExpense = false
    
    var body: some View {
        ZStack {
            // Delete Button Background
            HStack {
                Spacer()
                
                Button(action: {
                    deleteExpense()
                }) {
                    VStack(spacing: 3) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                        
                        Text("Delete")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white)
                    }
                    .frame(width: 60, height: 60)
                    .background(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .opacity(deleteManager.activeExpenseId == expense.id ? 1 : 0)
                .scaleEffect(deleteManager.activeExpenseId == expense.id ? 1 : 0.8)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: deleteManager.activeExpenseId == expense.id)
            }
            .padding(.trailing, 16)
            
            // Main Content
            HStack(spacing: 12) {
                Image(systemName: expense.category.icon)
                    .foregroundStyle(expense.category.color)
                    .font(.title3)
                    .frame(width: 36, height: 36)
                    .background(expense.category.color.opacity(0.15), in: Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    HStack {
                        Text(expense.category.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text(expense.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                Spacer()
                
                Text(formatCurrency(expense.amount, dataManager.user.currency))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .foregroundStyle(.primary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .offset(x: deleteManager.activeExpenseId == expense.id ? -76 : 0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: deleteManager.activeExpenseId == expense.id)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Only allow swipe left to reveal delete
                        if value.translation.width < -30 {
                            deleteManager.setActiveExpense(expense.id)
                        } else if value.translation.width > 30 && deleteManager.activeExpenseId == expense.id {
                            deleteManager.setActiveExpense(nil)
                        }
                    }
                    .onEnded { value in
                        // Snap behavior based on swipe distance
                        if value.translation.width < -50 {
                            deleteManager.setActiveExpense(expense.id)
                        } else if value.translation.width > 30 {
                            deleteManager.setActiveExpense(nil)
                        }
                    }
            )
            .onTapGesture {
                if deleteManager.activeExpenseId == expense.id {
                    // If delete button is showing, hide it
                    deleteManager.setActiveExpense(nil)
                } else {
                    // Otherwise, show edit sheet
                    showingEditExpense = true
                }
            }
        }
        .sheet(isPresented: $showingEditExpense) {
            EditExpenseView(expense: expense)
        }
    }
    
    private func deleteExpense() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            dataManager.deleteExpense(expense)
            deleteManager.setActiveExpense(nil)
        }
    }
    
    private func formatCurrency(_ amount: Double, _ currency: Currency) -> String {
        return CurrencyFormatter.format(amount, currency: currency)
    }
}

#Preview {
    ExpenseRowView(expense: Expense(
        title: "Coffee",
        amount: 4.50,
        category: .food,
        date: Date()
    ))
    .padding()
}
