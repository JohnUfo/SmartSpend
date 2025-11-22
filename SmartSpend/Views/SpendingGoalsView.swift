import SwiftUI

struct SpendingGoalsView: View {
    let goals: [SpendingGoal]
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingBudgetSettings = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Spending Goals", systemImage: "target")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button(action: { showingBudgetSettings = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.tint)
                }
            }
            
            LazyVStack(spacing: 12) {
                ForEach(goals.prefix(3)) { goal in
                    GoalProgressRow(goal: goal)
                }
                
                if goals.count > 3 {
                    Button(action: { showingBudgetSettings = true }) {
                        HStack {
                            Text("View All Goals (\(goals.count))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.tint)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundStyle(.tint)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .sheet(isPresented: $showingBudgetSettings) {
            BudgetSettingsView()
        }
    }
}

struct GoalProgressRow: View {
    let goal: SpendingGoal
    @ObservedObject private var dataManager = DataManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    Text("Target: \(CurrencyFormatter.format(goal.targetAmount, currency: dataManager.user.currency))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(CurrencyFormatter.format(goal.currentAmount, currency: dataManager.user.currency))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(goal.isCompleted ? .green : .primary)
                    
                    Text("\(Int(goal.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(goal.isCompleted ? .green : .blue)
                }
            }
            
            ProgressView(value: goal.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: goal.isCompleted ? .green : .blue))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
        }
        .padding(.vertical, 4)
    }
}
