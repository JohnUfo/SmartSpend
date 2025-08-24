import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var selectedTimeframe: TimeFrame = .month
    @State private var showingBudgetSettings = false
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Time Frame Picker
                    timeFramePicker
                    
                    // Spending Trends Chart
                    spendingTrendsChart
                    
                    // Category Budget Progress
                    categoryBudgetSection
                    
                    // Category Insights
                    categoryInsightsSection
                    
                    // Monthly Comparison
                    monthlyComparisonSection
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Budgets") {
                        showingBudgetSettings = true
                    }
                    .foregroundStyle(.tint)
                    .fontWeight(.medium)
                }
            }
            .sheet(isPresented: $showingBudgetSettings) {
                BudgetSettingsView()
            }
            .onAppear {
                dataManager.updateSpendingGoalProgress()
            }
        }
    }
    
    private var timeFramePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Time Period")
                .font(.headline)
                .fontWeight(.semibold)
            
            Picker("Time Frame", selection: $selectedTimeframe) {
                ForEach(TimeFrame.allCases, id: \.self) { timeFrame in
                    Text(timeFrame.rawValue).tag(timeFrame)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var spendingTrendsChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Spending Trends")
                .font(.headline)
                .fontWeight(.semibold)
            
            if #available(iOS 16.0, *) {
                Chart(getSpendingTrends()) { trend in
                    // Area fill for better visual impact
                    AreaMark(
                        x: .value("Date", trend.date),
                        y: .value("Amount", trend.amount)
                    )
                    .foregroundStyle(.linearGradient(
                        colors: [.blue.opacity(0.4), .blue.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    
                    // Main line for trend
                    LineMark(
                        x: .value("Date", trend.date),
                        y: .value("Amount", trend.amount)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    
                    // Data points for better visibility
                    PointMark(
                        x: .value("Date", trend.date),
                        y: .value("Amount", trend.amount)
                    )
                    .foregroundStyle(.white)
                    .symbolSize(6)
                    
                    // Outer ring for data points
                    PointMark(
                        x: .value("Date", trend.date),
                        y: .value("Amount", trend.amount)
                    )
                    .foregroundStyle(.blue)
                    .symbolSize(8)
                }
                .frame(height: 200)
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        guard let plotFrame = proxy.plotFrame else { return }
                        let x = value.location.x - geometry[plotFrame].origin.x
                                        guard let date = proxy.value(atX: x) as Date? else { return }
                                        
                                        // Find the closest data point
                                        let trends = getSpendingTrends()
                                        let closest = trends.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
                                        
                                        if let closest = closest {
                                            // You could add a tooltip here if needed
                                            print("Date: \(formatDateLabel(closest.date)), Amount: \(formatCompactCurrency(closest.amount, currency: dataManager.user.currency))")
                                        }
                                    }
                            )
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        if let amount = value.as(Double.self) {
                            AxisValueLabel {
                                Text(formatCompactCurrency(amount, currency: dataManager.user.currency))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(formatDateLabel(date))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } else {
                // Fallback for iOS < 16
                VStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Charts available in iOS 16+")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 200)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var categoryBudgetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Budget Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("Manage") {
                    showingBudgetSettings = true
                }
                .font(.subheadline)
                .foregroundStyle(.tint)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(dataManager.categoryBudgets.filter { $0.isEnabled }) { budget in
                    CategoryBudgetRow(budget: budget)
                }
                
                if dataManager.categoryBudgets.filter({ $0.isEnabled }).isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "target")
                            .font(.system(size: 30))
                            .foregroundStyle(.secondary)
                        Text("No budgets set")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Button("Set Budget") {
                            showingBudgetSettings = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var categoryInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Insights")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 12) {
                ForEach(getCategoryInsights()) { insight in
                    CategoryInsightRow(insight: insight)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    

    
    private var monthlyComparisonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Month vs Last Month")
                .font(.headline)
                .fontWeight(.semibold)
            
            let currentMonth = getCurrentMonthTotal()
            let previousMonth = getPreviousMonthTotal()
            let currentSalary = getCurrentMonthSalary()
            let previousSalary = getPreviousMonthSalary()
            let change = currentMonth - previousMonth
            let percentChange = previousMonth > 0 ? (change / previousMonth) * 100 : 0
            
            // Expenses Comparison
            VStack(alignment: .leading, spacing: 12) {
                Text("Expenses")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This Month")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(CurrencyFormatter.format(currentMonth, currency: dataManager.user.currency))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last Month")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(CurrencyFormatter.format(previousMonth, currency: dataManager.user.currency))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Change")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                .font(.caption)
                                .foregroundStyle(change >= 0 ? .red : .green)
                            
                            if percentChange > 1000 {
                                // For very large increases, show "8.2x" instead of "719.2%"
                                let multiplier = currentMonth / previousMonth
                                Text(String(format: "%.1fx", multiplier))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(change >= 0 ? .red : .green)
                            } else {
                                Text(String(format: "%.1f%%", abs(percentChange)))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(change >= 0 ? .red : .green)
                            }
                        }
                    }
                }
            }
            
            // Salary Comparison
            VStack(alignment: .leading, spacing: 12) {
                Text("Salary")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This Month")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(currentSalary > 0 ? CurrencyFormatter.format(currentSalary, currency: dataManager.user.currency) : "Not Set")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(currentSalary > 0 ? Color.green : Color.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last Month")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(previousSalary > 0 ? CurrencyFormatter.format(previousSalary, currency: dataManager.user.currency) : "Not Set")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(previousSalary > 0 ? Color.secondary : Color.orange)
                    }
                    
                    Spacer()
                }
            }
            
            // Savings Comparison
            if currentSalary > 0 || previousSalary > 0 {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Savings")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("This Month")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            let currentSavings = max(0, currentSalary - currentMonth)
                            Text(CurrencyFormatter.format(currentSavings, currency: dataManager.user.currency))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(currentSavings > 0 ? Color.green : Color.red)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Last Month")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            let previousSavings = max(0, previousSalary - previousMonth)
                            Text(CurrencyFormatter.format(previousSavings, currency: dataManager.user.currency))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(previousSavings > 0 ? Color.secondary : Color.red)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Helper Methods
    
    private func formatCompactCurrency(_ amount: Double, currency: Currency) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        
        if amount >= 1_000_000 {
            return "\(formatter.string(from: NSNumber(value: amount / 1_000_000)) ?? "0")M"
        } else if amount >= 1_000 {
            return "\(formatter.string(from: NSNumber(value: amount / 1_000)) ?? "0")K"
        } else {
            return formatter.string(from: NSNumber(value: amount)) ?? "0"
        }
    }
    
    private func formatDateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        
        switch selectedTimeframe {
        case .week:
            formatter.dateFormat = "E" // Mon, Tue, etc.
        case .month:
            formatter.dateFormat = "d" // Day number
        }
        
        return formatter.string(from: date)
    }
    
    private func getSpendingTrends() -> [SpendingTrend] {
        let calendar = Calendar.current
        let now = Date()
        let daysBack = selectedTimeframe == .week ? 7 : 30
        
        var trends: [SpendingTrend] = []
        
        for i in 0..<daysBack {
            if let date = calendar.date(byAdding: .day, value: -i, to: now) {
                let dayExpenses = dataManager.expenses.filter { calendar.isDate($0.date, inSameDayAs: date) }
                let totalAmount = dayExpenses.reduce(0) { $0 + $1.amount }
                
                trends.append(SpendingTrend(
                    period: DateFormatter.shortDate.string(from: date),
                    amount: totalAmount,
                    date: date
                ))
            }
        }
        
        return trends.reversed()
    }
    
    private func getCategoryInsights() -> [CategoryInsight] {
        let calendar = Calendar.current
        let now = Date()
        
        return ExpenseCategory.allCases.compactMap { category in
            // Current month expenses
            let currentMonthExpenses = dataManager.expenses.filter { expense in
                calendar.isDate(expense.date, equalTo: now, toGranularity: .month) && expense.category == category
            }
            let currentTotal = currentMonthExpenses.reduce(0) { $0 + $1.amount }
            
            // Previous month expenses
            guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return nil }
            let previousMonthExpenses = dataManager.expenses.filter { expense in
                calendar.isDate(expense.date, equalTo: previousMonth, toGranularity: .month) && expense.category == category
            }
            let previousTotal = previousMonthExpenses.reduce(0) { $0 + $1.amount }
            
            // Skip categories with no expenses
            guard currentTotal > 0 || previousTotal > 0 else { return nil }
            
            let change = currentTotal - previousTotal
            let percentageChange = previousTotal > 0 ? (change / previousTotal) * 100 : (currentTotal > 0 ? 100 : 0)
            
            let trend: CategoryInsight.TrendDirection
            if abs(percentageChange) < 5 {
                trend = .stable
            } else if percentageChange > 0 {
                trend = .up
            } else {
                trend = .down
            }
            
            return CategoryInsight(
                category: category,
                currentMonth: currentTotal,
                previousMonth: previousTotal,
                percentageChange: percentageChange,
                trend: trend
            )
        }
    }
    
    private func getCurrentMonthTotal() -> Double {
        let calendar = Calendar.current
        let now = Date()
        return dataManager.expenses.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func getPreviousMonthTotal() -> Double {
        let calendar = Calendar.current
        let now = Date()
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return 0 }
        return dataManager.expenses.filter { calendar.isDate($0.date, equalTo: previousMonth, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func getCurrentMonthSalary() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let month = calendar.component(.month, from: now)
        return dataManager.getSalaryForMonth(month: month, year: year)
    }
    
    private func getPreviousMonthSalary() -> Double {
        let calendar = Calendar.current
        let now = Date()
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: now) else { return 0 }
        let year = calendar.component(.year, from: previousMonth)
        let month = calendar.component(.month, from: previousMonth)
        return dataManager.getSalaryForMonth(month: month, year: year)
    }
}

// MARK: - Supporting Views

struct CategoryBudgetRow: View {
    let budget: CategoryBudget
    @ObservedObject private var dataManager = DataManager.shared
    
    private var spentAmount: Double {
        let calendar = Calendar.current
        let now = Date()
        return dataManager.expenses.filter { expense in
            calendar.isDate(expense.date, equalTo: now, toGranularity: .month) && expense.category == budget.category
        }.reduce(0) { $0 + $1.amount }
    }
    
    private var progress: Double {
        guard budget.amount > 0 else { return 0 }
        return min(spentAmount / budget.amount, 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(budget.category.rawValue, systemImage: budget.category.icon)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(CurrencyFormatter.format(spentAmount, currency: dataManager.user.currency)) / \(CurrencyFormatter.format(budget.amount, currency: dataManager.user.currency))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(progress > 0.8 ? .red : .primary)
                }
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progress > 1.0 ? .red : progress > 0.8 ? .orange : .green))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
        }
        .padding(.vertical, 8)
    }
}

struct CategoryInsightRow: View {
    let insight: CategoryInsight
    @ObservedObject private var dataManager = DataManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: insight.category.icon)
                .foregroundStyle(insight.category.color)
                .font(.title3)
                .frame(width: 36, height: 36)
                .background(insight.category.color.opacity(0.15), in: Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                HStack {
                    Text(CurrencyFormatter.format(insight.currentMonth, currency: dataManager.user.currency))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if insight.previousMonth > 0 {
                        Text("vs \(CurrencyFormatter.format(insight.previousMonth, currency: dataManager.user.currency))")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: trendIcon)
                    .font(.caption)
                    .foregroundStyle(trendColor)
                
                if abs(insight.percentageChange) >= 1 {
                    Text("\(Int(abs(insight.percentageChange)))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(trendColor)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var trendIcon: String {
        switch insight.trend {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "minus"
        }
    }
    
    private var trendColor: Color {
        switch insight.trend {
        case .up: return .red
        case .down: return .green
        case .stable: return .secondary
        }
    }
}

// MARK: - Extensions

extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
}

#Preview {
    AnalyticsView()
}
