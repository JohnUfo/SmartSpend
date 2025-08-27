import SwiftUI

struct DashboardView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var tabManager = TabManager.shared
    @State private var showingAddExpense = false
    @State private var showingBudgetDetails = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Budget Overview
                    BudgetOverviewView(
                        totalExpenses: dataManager.getTotalExpensesForPeriod(),
                        remainingBudget: dataManager.getRemainingBudgetForPeriod(),
                        salary: dataManager.getCurrentSalaryForPeriod(),
                        currency: dataManager.user.currency
                    )
                    .padding(.horizontal)
                    .onTapGesture {
                        showingBudgetDetails = true
                    }
                    
                    // Category Breakdown
                    CategoryBreakdownView(
                        categoryTotals: Dictionary(uniqueKeysWithValues: dataManager.getCategoryBreakdownForPeriod())
                    )
                    .padding(.horizontal)
                    
                    // Spending Trends
                    SpendingTrendsView()
                        .padding(.horizontal)
                    
                    // Spending Goals
                    if !dataManager.spendingGoals.isEmpty {
                        SpendingGoalsView(goals: dataManager.spendingGoals)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("SmartSpend")
            .navigationBarTitleDisplayMode(.large)
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
            .sheet(isPresented: $showingBudgetDetails) {
                BudgetDetailsView()
            }
            .onTapGesture {
                DeleteButtonManager.shared.setActiveExpense(nil)
            }
        }
    }
}

struct BudgetDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingCustomMonthPicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time Period Selector
                    timePeriodSelector
                    
                    // Budget Overview Card
                    budgetOverviewCard
                    
                    // Category Breakdown
                    categoryBreakdownCard
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Budget Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingCustomMonthPicker) {
                CustomMonthPickerView()
                    .presentationDetents([.fraction(0.85)])
            }
        }
    }
    
    private var timePeriodSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time Period")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            // Show custom date range if custom month is selected
            if dataManager.selectedTimePeriod == .customMonth {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Custom Date Range")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        Text("\(formatDate(dataManager.customStartDate)) - \(formatDate(dataManager.customEndDate))")
                            .font(.caption)
                            .foregroundStyle(.primary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingCustomMonthPicker = true
                    }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.tint)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Button(action: {
                        if period == .customMonth {
                            showingCustomMonthPicker = true
                        } else {
                            dataManager.selectedTimePeriod = period
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: period.icon)
                                .font(.title3)
                                .foregroundStyle(dataManager.selectedTimePeriod == period ? .white : .primary)
                            
                            Text(period.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(dataManager.selectedTimePeriod == period ? .white : .primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            dataManager.selectedTimePeriod == period ? 
                            Color(.systemBlue) : 
                            Color(.systemGray6),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    dataManager.selectedTimePeriod == period ? Color.clear : Color(.systemGray4),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.2), value: dataManager.selectedTimePeriod)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var budgetOverviewCard: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Label("Budget Overview", systemImage: "chart.pie.fill")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Spacer()
            }
            
            // Progress Section
            VStack(spacing: 12) {
                HStack {
                    Text("Budget Used")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(dataManager.getProgressPercentageForPeriod() * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(dataManager.getProgressPercentageForPeriod() > 0.8 ? .red : .primary)
                }
                
                ProgressView(value: dataManager.getProgressPercentageForPeriod())
                    .progressViewStyle(LinearProgressViewStyle(tint: dataManager.getProgressPercentageForPeriod() > 0.8 ? Color(.systemRed) : Color(.systemBlue)))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Budget Stats
            HStack(spacing: 16) {
                BudgetStatView(
                    title: "Spent",
                    amount: dataManager.getTotalExpensesForPeriod(),
                    currency: dataManager.user.currency,
                    color: Color(.systemRed)
                )
                
                Divider()
                    .frame(height: 40)
                
                BudgetStatView(
                    title: "Remaining",
                    amount: dataManager.getRemainingBudgetForPeriod(),
                    currency: dataManager.user.currency,
                    color: Color(.systemGreen)
                )
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var categoryBreakdownCard: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Category Breakdown", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(dataManager.getCategoryBreakdownForPeriod().prefix(5), id: \.0) { category, amount in
                    CategoryBreakdownRow(
                        category: category,
                        amount: amount,
                        total: dataManager.getTotalExpensesForPeriod(),
                        currency: dataManager.user.currency
                    )
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }
    
}

struct SpendingTrendsView: View {
    @ObservedObject private var dataManager = DataManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Spending Trends", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Spacer()
            }
            
            // Simple trend indicators
            HStack(spacing: 20) {
                TrendIndicator(
                    title: "Daily Avg",
                    value: dataManager.getDailyAverageForPeriod(),
                    currency: dataManager.user.currency,
                    trend: .up
                )
                
                TrendIndicator(
                    title: "Weekly Avg",
                    value: dataManager.getWeeklyAverageForPeriod(),
                    currency: dataManager.user.currency,
                    trend: .down
                )
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct CategoryBreakdownRow: View {
    let category: ExpenseCategory
    let amount: Double
    let total: Double
    let currency: Currency
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return amount / total
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .foregroundStyle(category.color)
                .font(.title3)
                .frame(width: 32, height: 32)
                .background(category.color.opacity(0.15), in: Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text("\(Int(percentage * 100))% of total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(CurrencyFormatter.format(amount, currency: currency))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 8)
    }
}

struct TrendIndicator: View {
    let title: String
    let value: Double
    let currency: Currency
    let trend: TrendDirection
    
    enum TrendDirection {
        case up, down, stable
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: trendIcon)
                    .font(.caption)
                    .foregroundStyle(trendColor)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(CurrencyFormatter.format(value, currency: currency))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
    }
    
    private var trendIcon: String {
        switch trend {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "minus"
        }
    }
    
    private var trendColor: Color {
        switch trend {
        case .up: return .red
        case .down: return .green
        case .stable: return .secondary
        }
    }
}

struct SalaryHeaderView: View {
    let salary: Double
    let currency: Currency
    let onEditSalary: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Monthly Salary", systemImage: "dollarsign.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button(action: onEditSalary) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.tint)
                }
                .buttonStyle(.borderless)
            }
            
            Text(formatCurrency(salary, currency))
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func formatCurrency(_ amount: Double, _ currency: Currency) -> String {
        return CurrencyFormatter.format(amount, currency: currency)
    }
}

struct BudgetOverviewView: View {
    let totalExpenses: Double
    let remainingBudget: Double
    let salary: Double
    let currency: Currency
    
    var progressPercentage: Double {
        guard salary > 0 else { return 0 }
        return min(totalExpenses / salary, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Label("Budget Overview", systemImage: "chart.pie.fill")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Spacer()
            }
            
            // Progress Section
            VStack(spacing: 12) {
                HStack {
                    Text("Budget Used")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(progressPercentage * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(progressPercentage > 0.8 ? .red : .primary)
                }
                
                ProgressView(value: progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressPercentage > 0.8 ? Color(.systemRed) : Color(.systemBlue)))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Budget Stats
            HStack(spacing: 16) {
                BudgetStatView(
                    title: "Spent",
                    amount: totalExpenses,
                    currency: currency,
                    color: Color(.systemRed)
                )
                
                Divider()
                    .frame(height: 40)
                
                BudgetStatView(
                    title: "Remaining",
                    amount: remainingBudget,
                    currency: currency,
                    color: Color(.systemGreen)
                )
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct BudgetStatView: View {
    let title: String
    let amount: Double
    let currency: Currency
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            Text(formatCurrency(amount, currency))
                .font(.title3)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func formatCurrency(_ amount: Double, _ currency: Currency) -> String {
        return CurrencyFormatter.format(amount, currency: currency)
    }
}

struct CategoryBreakdownView: View {
    let categoryTotals: [ExpenseCategory: Double]
    
    var sortedCategories: [(ExpenseCategory, Double)] {
        categoryTotals.sorted { $0.value > $1.value }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Category Breakdown", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Spacer()
            }
            
            if sortedCategories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    
                    Text("No expenses yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(sortedCategories.prefix(5), id: \.0) { category, amount in
                        CategoryRowView(category: category, amount: amount)
                    }
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct CategoryRowView: View {
    let category: ExpenseCategory
    let amount: Double
    @ObservedObject private var dataManager = DataManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .foregroundStyle(category.color)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(category.color.opacity(0.15), in: Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            Text(formatCurrency(amount, dataManager.user.currency))
                .font(.subheadline)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Double, _ currency: Currency) -> String {
        return CurrencyFormatter.format(amount, currency: currency)
    }
}

struct CustomMonthPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
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
                // Header with Instructions
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
            .navigationTitle("Select Custom Date Range")
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
                        dataManager.updateCustomDateRange(startDate: tempStartDate, endDate: tempEndDate)
                        dataManager.selectedTimePeriod = .customMonth
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                currentMonth = dataManager.customStartDate
                tempStartDate = dataManager.customStartDate
                tempEndDate = dataManager.customEndDate
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
        case .secondDate:
            tempEndDate = date
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
}



#Preview {
    DashboardView()
}
