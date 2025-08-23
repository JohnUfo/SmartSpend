import SwiftUI

struct DeletedExpensesView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: ExpenseCategory?
    
    var filteredDeletedExpenses: [ArchivedExpense] {
        var expenses = dataManager.deletedExpenses.sorted { $0.archivedDate > $1.archivedDate }
        
        if !searchText.isEmpty {
            expenses = expenses.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let selectedCategory = selectedCategory {
            expenses = expenses.filter { $0.category == selectedCategory }
        }
        
        return expenses
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        
                        TextField("Search deleted expenses...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            CategoryFilterButton(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(ExpenseCategory.allCases, id: \.self) { category in
                                CategoryFilterButton(
                                    title: category.rawValue,
                                    icon: category.icon,
                                    color: category.color,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(.regularMaterial)
                
                // Deleted Expenses List
                if filteredDeletedExpenses.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: searchText.isEmpty && selectedCategory == nil ? "archivebox" : "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundStyle(.tertiary)
                        
                        VStack(spacing: 8) {
                            Text(searchText.isEmpty && selectedCategory == nil ? "No Deleted Expenses" : "No Deleted Expenses Found")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            if !searchText.isEmpty || selectedCategory != nil {
                                Text("Try adjusting your search or filters")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                            } else {
                                Text("Deleted expenses will appear here")
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        ForEach(filteredDeletedExpenses) { deletedExpense in
                            DeletedExpenseRowView(deletedExpense: deletedExpense)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing) {
                                    Button("Restore") {
                                        dataManager.restoreExpense(deletedExpense)
                                    }
                                    .tint(.green)
                                    
                                    Button("Delete", role: .destructive) {
                                        dataManager.permanentlyDeleteExpense(deletedExpense)
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Deleted Expenses")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DeletedExpenseRowView: View {
    let deletedExpense: ArchivedExpense
    @ObservedObject private var dataManager = DataManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: deletedExpense.category.icon)
                .foregroundStyle(deletedExpense.category.color)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(deletedExpense.category.color.opacity(0.15), in: Circle())
            
            // Expense Details
            VStack(alignment: .leading, spacing: 4) {
                Text(deletedExpense.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text(deletedExpense.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(deletedExpense.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                HStack {
                    Text("Deleted \(deletedExpense.archivedDate, style: .date)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                    
                    let daysRemaining = dataManager.getDaysRemainingForExpense(deletedExpense)
                    if daysRemaining > 0 {
                        Text("\(daysRemaining) days left")
                            .font(.caption2)
                            .foregroundStyle(daysRemaining <= 7 ? .red : .orange)
                            .fontWeight(.medium)
                    } else {
                        Text("Expired")
                            .font(.caption2)
                            .foregroundStyle(.red)
                            .fontWeight(.medium)
                    }
                }
            }
            
            Spacer()
            
            // Amount
            Text(formatCurrency(deletedExpense.amount, dataManager.user.currency))
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 12)
        .opacity(0.7)
    }
    
    private func formatCurrency(_ amount: Double, _ currency: Currency) -> String {
        return CurrencyFormatter.format(amount, currency: currency)
    }
}

#Preview {
    DeletedExpensesView()
}
