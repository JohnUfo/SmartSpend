import SwiftUI

struct ExpenseListView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var searchText = ""
    @State private var selectedCategory: ExpenseCategory?
    @State private var selectedTimePeriod: TimePeriod = .all
    @State private var selectedCustomMonth: Date = Date()
    @State private var showingMonthPicker = false
    @State private var showingAddExpense = false
    
    enum TimePeriod: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case weekly = "This Week"
        case monthly = "This Month"
        case customMonth = "Custom Month"
        
        var icon: String {
            switch self {
            case .all: return "calendar"
            case .today: return "calendar.badge.exclamationmark"
            case .weekly: return "calendar.badge.clock"
            case .monthly: return "calendar.badge.plus"
            case .customMonth: return "calendar.badge.ellipsis"
            }
        }
    }
    
    var filteredExpenses: [Expense] {
        var expenses = dataManager.expenses.sorted { $0.date > $1.date }
        
        // Apply time period filter
        expenses = expenses.filter { expense in
            switch selectedTimePeriod {
            case .all:
                return true
            case .today:
                return Calendar.current.isDateInToday(expense.date)
            case .weekly:
                let calendar = Calendar.current
                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
                return expense.date >= startOfWeek
            case .monthly:
                let calendar = Calendar.current
                let startOfMonth = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
                return expense.date >= startOfMonth
            case .customMonth:
                let calendar = Calendar.current
                let startOfSelectedMonth = calendar.dateInterval(of: .month, for: selectedCustomMonth)?.start ?? Date()
                let endOfSelectedMonth = calendar.dateInterval(of: .month, for: selectedCustomMonth)?.end ?? Date()
                return expense.date >= startOfSelectedMonth && expense.date < endOfSelectedMonth
            }
        }
        
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
                        
                        TextField("Search expenses...", text: $searchText)
                            .textFieldStyle(.plain)
                            .onSubmit {
                                hideKeyboard()
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                hideKeyboard()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                                    .font(.system(size: 16))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                    
                    // Time Period Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(TimePeriod.allCases, id: \.self) { timePeriod in
                                TimePeriodFilterButton(
                                    timePeriod: timePeriod,
                                    isSelected: selectedTimePeriod == timePeriod,
                                    action: { 
                                        if timePeriod == .customMonth {
                                            showingMonthPicker = true
                                        } else {
                                            selectedTimePeriod = timePeriod
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
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
                
                // Expenses List
                if filteredExpenses.isEmpty {
                    EmptyStateView(
                        searchText: searchText,
                        hasFilter: selectedCategory != nil
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredExpenses) { expense in
                                ExpenseRowView(expense: expense)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(.tint)
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
            .sheet(isPresented: $showingMonthPicker) {
                MonthPickerView(selectedDate: $selectedCustomMonth, selectedTimePeriod: $selectedTimePeriod)
                    .presentationDetents([.height(280)])
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
}

struct MonthPickerView: View {
    @Binding var selectedDate: Date
    @Binding var selectedTimePeriod: ExpenseListView.TimePeriod
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMonth: Int
    @State private var selectedYear: Int
    
    init(selectedDate: Binding<Date>, selectedTimePeriod: Binding<ExpenseListView.TimePeriod>) {
        self._selectedDate = selectedDate
        self._selectedTimePeriod = selectedTimePeriod
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .year], from: selectedDate.wrappedValue)
        self._selectedMonth = State(initialValue: components.month ?? 1)
        self._selectedYear = State(initialValue: components.year ?? calendar.component(.year, from: Date()))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack(spacing: 0) {
                    // Month Picker
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { month in
                            Text(monthName(month))
                                .tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                    
                    // Year Picker
                    Picker("Year", selection: $selectedYear) {
                        ForEach(2020...2030, id: \.self) { year in
                            Text(String(year))
                                .tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity)
                }
                .onChange(of: selectedMonth) { _, _ in
                    updateSelectedDate()
                }
                .onChange(of: selectedYear) { _, _ in
                    updateSelectedDate()
                }
            }
            .padding(.horizontal)
            .navigationTitle("Select Month")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        selectedTimePeriod = .customMonth
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func monthName(_ month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        return dateFormatter.monthSymbols[month - 1]
    }
    
    private func updateSelectedDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        
        if let newDate = Calendar.current.date(from: components) {
            selectedDate = newDate
        }
    }
}

struct TimePeriodFilterButton: View {
    let timePeriod: ExpenseListView.TimePeriod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: timePeriod.icon)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(timePeriod.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected ? 
                Color(.systemBlue) : 
                Color(.systemGray6),
                in: Capsule()
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : Color(.systemGray4), 
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct CategoryFilterButton: View {
    let title: String
    var icon: String?
    var color: Color?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                isSelected ? 
                (color ?? Color(.systemBlue)) : 
                Color(.systemGray6),
                in: Capsule()
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ? Color.clear : Color(.systemGray4), 
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct EmptyStateView: View {
    let searchText: String
    let hasFilter: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: searchText.isEmpty && !hasFilter ? "list.bullet.rectangle" : "magnifyingglass")
                .font(.system(size: 50))
                .foregroundStyle(.tertiary)
            
            VStack(spacing: 8) {
                Text(searchText.isEmpty && !hasFilter ? "No Expenses Yet" : "No Expenses Found")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                if searchText.isEmpty && !hasFilter {
                    Text("Tap + to add your first expense")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Try adjusting your search or filters")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ExpenseListView()
}

// MARK: - Keyboard Dismissal
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
