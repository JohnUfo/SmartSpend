import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory: ExpenseCategory = .food
    @State private var selectedDate = Date()
    @State private var showingSuggestions = false
    @State private var categorySuggestions: [(category: ExpenseCategory, confidence: Double)] = []
    @State private var suggestedPrice: Double?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    // Title Field with Auto-completion
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Expense title", text: $title, axis: .vertical)
                            .textFieldStyle(.plain)
                            .onChange(of: title) { _, _ in
                                checkForSuggestions()
                            }
                        
                        if showingSuggestions && !categorySuggestions.isEmpty {
                            EnhancedSuggestionView(
                                categorySuggestions: categorySuggestions,
                                suggestedPrice: suggestedPrice,
                                currency: dataManager.user.currency,
                                onCategorySelect: { category in
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        self.selectedCategory = category
                                        // Don't dismiss suggestions - let user also select price if they want
                                    }
                                },
                                onPriceSelect: { price in
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        self.amount = formatNumberWithCommas(price)
                                        // Don't dismiss suggestions - let user also select category if they want
                                    }
                                },
                                onDismiss: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        self.showingSuggestions = false
                                    }
                                }
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    // Amount Field
                    HStack {
                        Text(dataManager.user.currency.symbol)
                            .foregroundStyle(.secondary)
                            .font(.body)
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.plain)
                            .onChange(of: amount) {
                                formatAmountInput()
                            }
                    }
                    
                    // Category Picker
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .foregroundStyle(category.color)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // Date Picker
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                } header: {
                    Text("Expense Details")
                } footer: {
                    Text("Enter your expense details. Smart suggestions will appear based on your previous entries.")
                        .font(.caption)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.tint)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(title.isEmpty || amount.isEmpty || getNumericValue(from: amount) == nil)
                    .fontWeight(.semibold)
                    .foregroundStyle(title.isEmpty || amount.isEmpty || getNumericValue(from: amount) == nil ? Color.secondary : Color.accentColor)
                }
            }
        }
    }
    
    private func checkForSuggestions() {
        guard !title.isEmpty else {
            showingSuggestions = false
            return
        }
        
        // Check if smart suggestions are enabled (need at least 3 expenses to start learning)
        guard dataManager.expenses.count >= 3 else {
            print("🔍 Smart Learning: Not enough expenses (\(dataManager.expenses.count)/3)")
            showingSuggestions = false
            return
        }
        
        // Get category predictions
        let categoryPreds = dataManager.getTopCategorySuggestions(for: title, limit: 3)
        
        // Get price suggestions from similar patterns
        let suggestions = dataManager.getCategoryFocusedSuggestions(for: title)
        let priceSuggestion = suggestions.first?.mostUsedPrice
        
        print("🔍 Smart Learning Debug for '\(title)':")
        print("   Total patterns: \(dataManager.learnedPatterns.count)")
        print("   Found suggestions: \(suggestions.count)")
        print("   Category predictions: \(categoryPreds.count)")
        
        if !categoryPreds.isEmpty {
            categorySuggestions = categoryPreds
            suggestedPrice = priceSuggestion
            showingSuggestions = true
            print("   ✅ Showing suggestions")
        } else {
            showingSuggestions = false
            print("   ❌ No suggestions found")
        }
    }
    
    private func saveExpense() {
        guard let amountValue = getNumericValue(from: amount), !title.isEmpty else { return }
        
        let expense = Expense(
            title: title,
            amount: amountValue,
            category: selectedCategory,
            date: selectedDate
        )
        
        dataManager.addExpense(expense)
        dismiss()
    }
    
    private func formatAmountInput() {
        // Remove all non-numeric characters except decimal point
        let cleanedInput = amount.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        
        // Convert to number and format with commas
        if let number = Double(cleanedInput) {
            let formatted = formatNumberWithCommas(number)
            if formatted != amount {
                amount = formatted
            }
        }
    }
    
    private func formatNumberWithCommas(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
    
    private func getNumericValue(from text: String) -> Double? {
        // Remove commas and convert to double
        let cleanedText = text.replacingOccurrences(of: ",", with: "")
        return Double(cleanedText)
    }
}

struct EnhancedSuggestionView: View {
    let categorySuggestions: [(category: ExpenseCategory, confidence: Double)]
    let suggestedPrice: Double?
    let currency: Currency
    let onCategorySelect: (ExpenseCategory) -> Void
    let onPriceSelect: (Double) -> Void
    let onDismiss: () -> Void
    
    @State private var selectedCategory: ExpenseCategory?
    @State private var selectedPrice: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            suggestionHeader
            
            // Category Suggestions
            categorySection
            
            // Price Suggestion
            if let price = suggestedPrice {
                Divider()
                priceSection(price: price)
            }
            
            // Helper text
            if selectedCategory != nil || selectedPrice != nil {
                Divider()
                helperText
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemBlue).opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - View Components
    
    private var suggestionHeader: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(Color(.systemBlue))
                .font(.caption)
            Text("Smart Suggestions")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Likely Categories:")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            ForEach(categorySuggestions, id: \.category) { suggestion in
                categoryButton(for: suggestion)
            }
        }
    }
    
    private func categoryButton(for suggestion: (category: ExpenseCategory, confidence: Double)) -> some View {
        let isSelected = selectedCategory == suggestion.category
        
        return Button {
            selectedCategory = suggestion.category
            onCategorySelect(suggestion.category)
        } label: {
            HStack {
                Label(suggestion.category.rawValue, systemImage: suggestion.category.icon)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .white : suggestion.category.color)
                
                Spacer()
                
                Text("\(Int(suggestion.confidence * 100))%")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                isSelected ? suggestion.category.color : Color(.systemGray6),
                in: RoundedRectangle(cornerRadius: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? suggestion.category.color : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func priceSection(price: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggested Price:")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            priceButton(price: price)
        }
    }
    
    private func priceButton(price: Double) -> some View {
        let isSelected = selectedPrice == price
        
        return Button {
            selectedPrice = price
            onPriceSelect(price)
        } label: {
            HStack {
                Text(formatCurrency(price, currency))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? .white : .primary)
                
                Spacer()
                
                Text(isSelected ? "Selected" : "Use Price")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        isSelected ? .green : .blue,
                        in: RoundedRectangle(cornerRadius: 6)
                    )
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                isSelected ? .green.opacity(0.2) : Color(.systemGray6),
                in: RoundedRectangle(cornerRadius: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? .green : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var helperText: some View {
        Text("💡 You can select both price and category, or tap X to close")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }
    
    private func formatCurrency(_ amount: Double, _ currency: Currency) -> String {
        return CurrencyFormatter.format(amount, currency: currency)
    }
}

struct SuggestionView: View {
    let price: Double
    let category: ExpenseCategory
    let currency: Currency
    let onAccept: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color(.systemBlue))
                    .font(.caption)
                Text("Smart Suggestion")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatCurrency(price, currency))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Label(category.rawValue, systemImage: category.icon)
                        .font(.caption)
                        .foregroundStyle(category.color)
                }
                
                Spacer()
                
                Button(action: {
                    onAccept()
                }) {
                    Text("Use")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding(12)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemBlue).opacity(0.2), lineWidth: 1)
        )
    }
    
    private func formatCurrency(_ amount: Double, _ currency: Currency) -> String {
        return CurrencyFormatter.format(amount, currency: currency)
    }
}

#Preview {
    AddExpenseView()
}
