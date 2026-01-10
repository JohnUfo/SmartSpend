import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date = Date()
}

struct SupportChatView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(content: "Hi there! I'm your SmartSpend AI assistant & Personal Accountant. How can I help you analyze your finances today?", isUser: false)
    ]
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat Header
                HStack(spacing: 12) {
                    Circle()
                        .fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "sparkles")
                                .foregroundStyle(.white)
                                .font(.system(size: 20))
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("support_agent_name".localized)
                            .font(.headline)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text("support_agent_status".localized)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) {
                        withAnimation {
                            proxy.scrollTo(messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                // Input Area
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 12) {
                        TextField("chat_placeholder".localized, text: $messageText, axis: .vertical)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .focused($isFocused)
                            .lineLimit(1...5)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(messageText.isEmpty ? Color.secondary : Color.blue)
                        }
                        .disabled(messageText.isEmpty)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(.ultraThinMaterial)
            }
            .navigationTitle("support".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done".localized) { dismiss() }
                        .fontWeight(.medium)
                }
            }
        }
    }
    
    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        print("💬 AI Chat: User sent message: '\(trimmedMessage)'")
        
        // Immediately clear input and unfocus
        messageText = ""
        isFocused = false
        
        let userMessage = ChatMessage(content: trimmedMessage, isUser: true)
        withAnimation {
            messages.append(userMessage)
        }
        
        // Simulate AI thinking
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let responseText = generateIntelligentResponse(for: trimmedMessage)
            print("🤖 AI Chat: Accountant responded: '\(responseText)'")
            withAnimation {
                messages.append(ChatMessage(content: responseText, isUser: false))
            }
        }
    }
    
    private func generateIntelligentResponse(for input: String) -> String {
        let lowercaseInput = " \(input.lowercased()) "
        let currency = dataManager.user.currency
        let calendar = Calendar.current
        let now = Date()
        
        print("🔍 AI Deep Analysis: Parsing input intent...")
        
        // --- 1. DATE RANGE PARSING ---
        var startDate: Date? = nil
        var endDate: Date = now
        var dateLabel = ""
        
        if lowercaseInput.contains(" today ") {
            startDate = calendar.startOfDay(for: now)
            dateLabel = "today"
        } else if lowercaseInput.contains(" yesterday ") {
            startDate = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))
            endDate = calendar.startOfDay(for: now)
            dateLabel = "yesterday"
        } else if lowercaseInput.contains(" this week ") || lowercaseInput.contains(" current week ") {
            startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))
            dateLabel = "this week"
        } else if lowercaseInput.contains(" this month ") || lowercaseInput.contains(" current month ") {
            startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: now))
            dateLabel = "this month"
        } else if lowercaseInput.contains(" this year ") || lowercaseInput.contains(" current year ") {
            startDate = calendar.date(from: calendar.dateComponents([.year], from: now))
            dateLabel = "this year"
        } else if lowercaseInput.contains(" from ") || lowercaseInput.contains(" to ") || lowercaseInput.contains(" between ") {
            // Complex range detection fallback
            dateLabel = "the specified range"
            // Note: In a production app, we'd use DataDetector here. 
            // For now, we'll check common month names.
            let months = ["january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december"]
            for (index, month) in months.enumerated() {
                if lowercaseInput.contains(month) {
                    var comps = DateComponents()
                    comps.month = index + 1
                    comps.year = calendar.component(.year, from: now)
                    startDate = calendar.date(from: comps)
                    endDate = calendar.date(byAdding: .month, value: 1, to: startDate!)!
                    dateLabel = month.capitalized
                    break
                }
            }
        }
        
        let filteredExpenses = dataManager.expenses.filter { expense in
            if let start = startDate {
                return expense.date >= start && expense.date <= endDate
            }
            return true
        }

        // --- 2. INTENT CLASSIFICATION ---
        
        // A. Category Analysis (Which categories used? Top category?)
        if lowercaseInput.contains(" category ") || lowercaseInput.contains(" categories ") || lowercaseInput.contains(" where ") || lowercaseInput.contains(" top ") || lowercaseInput.contains(" most ") {
            print("🏷 AI Analysis: Category Focus")
            let breakdown = groupExpensesByCategory(filteredExpenses)
            if breakdown.isEmpty {
                return "I don't see any categorized expenses for \(dateLabel.isEmpty ? "this period" : dateLabel)."
            }
            
            if lowercaseInput.contains(" list ") || lowercaseInput.contains(" which ") || lowercaseInput.contains(" what kind ") {
                let categoryNames = breakdown.keys.map { $0.name }.joined(separator: ", ")
                return "For \(dateLabel.isEmpty ? "all time" : dateLabel), you used these categories: \(categoryNames). Total of \(breakdown.count) different categories."
            }
            
            if let top = breakdown.max(by: { $0.value < $1.value }) {
                let amount = CurrencyFormatter.format(top.value, currency: currency)
                return "Your highest spending was in '\(top.key.name)' with \(amount) spent \(dateLabel.isEmpty ? "in total" : "during " + dateLabel)."
            }
        }
        
        // B. Spending Breakdown (How much spent?)
        if lowercaseInput.contains(" spent ") || lowercaseInput.contains(" spending ") || lowercaseInput.contains(" total ") || lowercaseInput.contains(" how much ") {
            print("📈 AI Analysis: Spending Focus")
            let total = filteredExpenses.reduce(0) { $0 + $1.amount }
            let formattedTotal = CurrencyFormatter.format(total, currency: currency)
            
            if !dateLabel.isEmpty {
                return "You spent a total of \(formattedTotal) \(dateLabel). This includes \(filteredExpenses.count) transactions."
            }
            
            return "Your total spending is \(formattedTotal) across \(filteredExpenses.count) transactions recorded in the app."
        }
        
        // C. Last/Recent Transaction
        if lowercaseInput.contains(" last ") || lowercaseInput.contains(" recent ") || lowercaseInput.contains(" latest ") {
            print("🕒 AI Analysis: Recency Focus")
            if let last = dataManager.expenses.sorted(by: { $0.date > $1.date }).first {
                let amount = CurrencyFormatter.format(last.amount, currency: currency)
                let date = last.date.formatted(date: .abbreviated, time: .shortened)
                return "The last thing you tracked was '\(last.title)' for \(amount) on \(date)."
            }
        }

        // D. Budget & Efficiency
        if lowercaseInput.contains(" budget ") || lowercaseInput.contains(" safe ") || lowercaseInput.contains(" remaining ") {
            print("💰 AI Analysis: Budget Focus")
            let salary = dataManager.getCurrentMonthSalary()
            let remaining = dataManager.getRemainingBudget()
            
            if salary == 0 { return "I need your monthly salary in Settings to calculate your remaining budget correctly." }
            
            if remaining < 0 {
                return "You're over budget by \(CurrencyFormatter.format(abs(remaining), currency: currency)). I suggest reviewing your '\(groupExpensesByCategory(dataManager.expenses).max(by: { $0.value < $1.value })?.key.name ?? "top")' spending."
            } else {
                return "You have \(CurrencyFormatter.format(remaining, currency: currency)) left this month. You've used \(Int((1 - (remaining/salary)) * 100))% of your income."
            }
        }

        // --- 3. FALLBACKS ---
        if lowercaseInput.contains(" hi ") || lowercaseInput.contains(" hello ") || lowercaseInput.contains(" hey ") {
            return "Hello! I'm your SmartSpend Accountant. I can analyze your spending by date ('this month', 'today') or by category ('top category', 'list categories'). What should I look at?"
        }

        return "I can analyze that for you. Try being specific, like 'how much did I spend this month' or 'what was my top category last year?'"
    }

    private func groupExpensesByCategory(_ expenses: [Expense]) -> [UserCategory: Double] {
        var groups: [UserCategory: Double] = [:]
        for exp in expenses {
            let cat = dataManager.resolveCategory(id: exp.categoryId)
            groups[cat, default: 0] += exp.amount
        }
        return groups
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isUser ? Color.blue : Color(.systemGray5))
                    .foregroundStyle(message.isUser ? .white : .primary)
                    .clipShape(BubbleShape(isUser: message.isUser))
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if !message.isUser { Spacer() }
        }
    }
}

struct BubbleShape: Shape {
    let isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                               byRoundingCorners: [.topLeft, .topRight, isUser ? .bottomLeft : .bottomRight],
                               cornerRadii: CGSize(width: 16, height: 16))
        return Path(path.cgPath)
    }
}

#Preview {
    SupportChatView()
}
