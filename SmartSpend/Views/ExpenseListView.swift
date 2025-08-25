import SwiftUI

struct ExpenseListView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var searchText = ""
    @State private var selectedCategory: ExpenseCategory?
    @State private var selectedTimePeriod: TimePeriod = .all
    @State private var selectedCustomMonth: Date = Date()
    @State private var selectedStartDate: Date = Date()
    @State private var selectedEndDate: Date = Date()
    @State private var showingMonthPicker = false
    @State private var showingAddExpense = false
    @State private var isDateRangeMode = true
    
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
            case .customMonth: return "calendar.badge.clock"
            }
        }
    }
    
    enum CustomDateMode: String, CaseIterable {
        case singleDate = "Single Date"
        case dateRange = "Date Range"
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
                if isDateRangeMode {
                    return expense.date >= selectedStartDate && expense.date <= selectedEndDate
                } else {
                    return calendar.isDate(expense.date, inSameDayAs: selectedStartDate)
                }
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
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(.regularMaterial)
                
                // Expenses List
                if filteredExpenses.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        
                        Text("No expenses found")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        Text("Try adjusting your filters or add a new expense")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 32)
                } else {
                    List {
                        ForEach(filteredExpenses) { expense in
                            ExpenseRowView(expense: expense)
                        }
                        .onDelete(perform: deleteExpense)
                    }
                    .listStyle(.plain)
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
                CalendarPickerView(
                    selectedStartDate: $selectedStartDate,
                    selectedEndDate: $selectedEndDate,
                    isDateRangeMode: $isDateRangeMode,
                    selectedTimePeriod: $selectedTimePeriod
                )
                .presentationDetents([.fraction(0.85)])
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private func deleteExpense(at offsets: IndexSet) {
        for index in offsets {
            let expense = filteredExpenses[index]
            dataManager.deleteExpense(expense)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CalendarPickerView: View {
    @Binding var selectedStartDate: Date
    @Binding var selectedEndDate: Date
    @Binding var isDateRangeMode: Bool
    @Binding var selectedTimePeriod: ExpenseListView.TimePeriod
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentMonth: Date = Date()
    @State private var selectionStep: SelectionStep = .firstDate
    @State private var tempStartDate: Date = Date()
    @State private var tempEndDate: Date = Date()
    
    enum SelectionStep {
        case firstDate
        case secondDate
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with Date Range Toggle
                VStack(spacing: 20) {

                    
                                    // Instructions
                Text(instructionText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // From and To Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        selectionStep = .firstDate
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 14, weight: .medium))
                            Text("From")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(selectionStep == .firstDate ? .white : .blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectionStep == .firstDate ? Color.blue : Color.blue.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        selectionStep = .secondDate
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 14, weight: .medium))
                            Text("To")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(selectionStep == .secondDate ? .white : .blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectionStep == .secondDate ? Color.blue : Color.blue.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)
                }
                }
                .padding(.top, 16)
                .padding(.bottom, 24)
                .background(Color(.systemGroupedBackground))
                
                // Calendar View
                VStack(spacing: 20) {
                    // Month Navigation
                    HStack {
                        Button(action: previousMonth) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(.systemBlue))
                                .frame(width: 36, height: 36)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Text(monthYearString(from: currentMonth))
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(.label))
                        
                        Spacer()
                        
                        Button(action: nextMonth) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(.systemBlue))
                                .frame(width: 36, height: 36)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Calendar Grid
                    VStack(spacing: 12) {
                        // Day headers
                        HStack(spacing: 0) {
                            ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { index, day in
                                Text(day)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(.secondaryLabel))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Calendar days
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                            ForEach(Array(calendarDays.enumerated()), id: \.offset) { index, date in
                                if let date = date {
                                    CalendarDayView(
                                        date: date,
                                        isSelected: isDateSelected(date),
                                        isInRange: isDateInRange(date),
                                        isCurrentMonth: Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month),
                                        isDateRangeMode: true
                                    ) {
                                        selectDate(date)
                                    }
                                } else {
                                    Color.clear
                                        .frame(height: 40)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                

                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        // Apply the selected date range when Done is pressed
                        selectedStartDate = tempStartDate
                        selectedEndDate = tempEndDate
                        selectedTimePeriod = .customMonth
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                currentMonth = selectedStartDate
                tempStartDate = selectedStartDate
                tempEndDate = selectedEndDate
            }
        }
    }
    
    private var calendarDays: [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        
        var days: [Date?] = []
        let endDate = calendar.date(byAdding: .day, value: 41, to: startOfWeek) ?? startOfWeek
        
        var currentDate = startOfWeek
        while currentDate < endDate {
            if calendar.isDate(currentDate, equalTo: currentMonth, toGranularity: .month) {
                days.append(currentDate)
            } else {
                days.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    private func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
    
    private func selectDate(_ date: Date) {
        switch selectionStep {
        case .firstDate:
            tempStartDate = date
            // Don't auto-switch to second date when using buttons
            // User can manually switch using the "To" button
        case .secondDate:
            tempEndDate = date
            // Don't auto-apply the range - wait for user to press Done
            // Stay in second date mode until user manually changes it
        }
    }
    

    
    private func isDateSelected(_ date: Date) -> Bool {
        switch selectionStep {
        case .firstDate:
            return Calendar.current.isDate(date, inSameDayAs: tempStartDate)
        case .secondDate:
            return Calendar.current.isDate(date, inSameDayAs: tempEndDate)
        }
    }
    
    private func isDateInRange(_ date: Date) -> Bool {
        // Don't show range highlighting - only show selected dates
        return false
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private var instructionText: String {
        switch selectionStep {
        case .firstDate:
            return "Tap 'From' button and select start date, then tap 'To' button and select end date"
        case .secondDate:
            return "Select the end date to complete your range"
        }
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isInRange: Bool
    let isCurrentMonth: Bool
    let isDateRangeMode: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(backgroundColor)
                )
                .foregroundColor(foregroundColor)
                .scaleEffect(isSelected ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color(.systemBlue)
        } else if isInRange {
            return Color(.systemBlue).opacity(0.15)
        } else {
            return .clear
        }
    }
    
    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if isCurrentMonth {
            return Color(.label)
        } else {
            return Color(.tertiaryLabel)
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
