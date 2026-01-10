import SwiftUI

struct DashboardView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingAddExpense = false
    @State private var selectedTimePeriod: TimePeriod = .thisMonth
    @State private var showingProblemExpenses = false
    
    // Check if there are any expenses that need attention
    private var hasProblemExpenses: Bool {
        dataManager.expenses.contains { $0.category == .other && $0.userCategoryId == nil }
    }
    
    private var problemExpensesCount: Int {
        dataManager.expenses.filter { $0.category == .other && $0.userCategoryId == nil }.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Problem Expenses Banner
                    if hasProblemExpenses {
                        Button(action: {
                            showingProblemExpenses = true
                        }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.white)
                                
                                Text("problem_expenses_title".localized)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Text("\(problemExpensesCount)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.orange)
                                    .padding(6)
                                    .background(.white, in: Circle())
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                            .padding()
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    
                    // Time Period Selector
                    TimePeriodSelector(selectedPeriod: $selectedTimePeriod)
                        .padding(.horizontal)
                        .padding(.top, hasProblemExpenses ? 0 : 20)
                    
                    // Budget Overview
                    BudgetOverviewCard(timePeriod: selectedTimePeriod)
                        .padding(.horizontal)
                    
                    // Spending Trends
                    SpendingTrendsCard(timePeriod: selectedTimePeriod)
                        .padding(.horizontal)
                    
                    // Category Breakdown
                    CategoryBreakdownCard(timePeriod: selectedTimePeriod)
                        .padding(.horizontal)
                        .padding(.bottom, 80) // Space for FAB
                }
            }
            .navigationTitle("dashboard".localized)
            .background(Color(.systemGroupedBackground))
            .overlay(alignment: .bottomTrailing) {
                FloatingAddButton(action: { showingAddExpense = true })
                    .padding()
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView()
            }
            .navigationDestination(isPresented: $showingProblemExpenses) {
                ProblemExpensesView()
            }
        }
    }
}

#Preview {
    DashboardView()
}

