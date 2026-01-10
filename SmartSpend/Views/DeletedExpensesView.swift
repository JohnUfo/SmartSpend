import SwiftUI

struct DeletedExpensesView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategoryId: UUID?
    
    var availableCategories: [UserCategory] {
        let uniqueCategoryIds = Set(dataManager.deletedExpenses.map { $0.categoryId })
        return uniqueCategoryIds.compactMap { id in
            dataManager.resolveCategory(id: id)
        }.sorted { $0.name < $1.name }
    }
    
    var filteredDeletedExpenses: [ArchivedExpense] {
        var expenses = dataManager.deletedExpenses.sorted { $0.archivedDate > $1.archivedDate }
        
        if !searchText.isEmpty {
            expenses = expenses.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let selectedCategoryId = selectedCategoryId {
            expenses = expenses.filter { $0.categoryId == selectedCategoryId }
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
                        
                        TextField("search_deleted_expenses".localized, text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                    
                    // Category Filter
                    if !availableCategories.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                CategoryFilterButton(
                                    title: "All",
                                    isSelected: selectedCategoryId == nil,
                                    action: { selectedCategoryId = nil }
                                )
                                
                                ForEach(availableCategories, id: \.self) { category in
                                    CategoryFilterButton(
                                        title: category.name,
                                        icon: category.iconSystemName,
                                        color: category.color,
                                        isSelected: selectedCategoryId == category.id,
                                        action: { selectedCategoryId = category.id }
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(.regularMaterial)
                
                // Deleted Expenses List
                if filteredDeletedExpenses.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: searchText.isEmpty && selectedCategoryId == nil ? "archivebox" : "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundStyle(.tertiary)
                        
                        VStack(spacing: 8) {
                            Text(searchText.isEmpty && selectedCategoryId == nil ? "no_deleted_expenses".localized : "no_deleted_expenses_found".localized)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            if !searchText.isEmpty || selectedCategoryId != nil {
                                Text("try_adjusting_filters_deleted".localized)
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                            } else {
                                Text("deleted_expenses_appear_here".localized)
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
                                    Button("restore_button".localized) {
                                        dataManager.restoreExpense(deletedExpense)
                                    }
                                    .tint(.green)
                                    
                                    Button("delete_button".localized, role: .destructive) {
                                        dataManager.permanentlyDeleteExpense(deletedExpense)
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("deleted_expenses_title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("done".localized) {
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
    
    // Helper to resolve the correct category display info
    private var categoryDisplayInfo: (name: String, icon: String, color: Color) {
        let category = dataManager.resolveCategory(id: deletedExpense.categoryId)
        return (category.name, category.iconSystemName, category.color)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: categoryDisplayInfo.icon)
                .foregroundStyle(categoryDisplayInfo.color)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(categoryDisplayInfo.color.opacity(0.15), in: Circle())
            
            // Expense Details
            VStack(alignment: .leading, spacing: 4) {
                Text(deletedExpense.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text(categoryDisplayInfo.name)
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
