import SwiftUI

struct MonthlySalaryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    @State private var salaryAmount: String = ""
    
    init(year: Int? = nil, month: Int? = nil) {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)
        
        _selectedYear = State(initialValue: year ?? currentYear)
        _selectedMonth = State(initialValue: month ?? currentMonth)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("month_year".localized) {
                    HStack(spacing: 0) {
                        Picker("month".localized, selection: $selectedMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text(monthName(month))
                                    .font(.title3)
                                    .tag(month)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        
                        Picker("year".localized, selection: $selectedYear) {
                            ForEach(2000...2100, id: \.self) { year in
                                Text(String(format: "%d", year))
                                    .font(.title3)
                                    .tag(year)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 120)
                }
                .onChange(of: selectedMonth) {
                    loadExistingSalary()
                }
                .onChange(of: selectedYear) {
                    loadExistingSalary()
                }
                
                Section("amount".localized) {
                    HStack {
                        Text(dataManager.user.currency.symbol)
                            .font(.title2)
                            .foregroundColor(.blue)
                        TextField("0", text: $salaryAmount)
                            .font(.title2)
                            .keyboardType(.decimalPad)
                            .onChange(of: salaryAmount) {
                                formatAmountInput()
                            }
                    }
                }
            }
            .navigationTitle("monthly_salary_title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("save".localized) {
                        saveSalary()
                        dismiss()
                    }
                    .disabled(salaryAmount.isEmpty || getNumericValue(from: salaryAmount) == nil)
                }
            }
            .onAppear {
                loadExistingSalary()
            }
        }
    }
    
    private func monthName(_ month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        var components = DateComponents()
        components.year = 2024
        components.month = month
        components.day = 1
        
        if let date = Calendar.current.date(from: components) {
            return dateFormatter.string(from: date)
        }
        return "Month \(month)"
    }
    
    private func getExistingSalary() -> Double? {
        return dataManager.monthlySalaries.first { $0.year == selectedYear && $0.month == selectedMonth }?.amount
    }
    
    private func loadExistingSalary() {
        if let existingSalary = getExistingSalary() {
            salaryAmount = formatNumberWithCommas(existingSalary)
        } else {
            salaryAmount = ""
        }
    }
    
    private func saveSalary() {
        guard let amount = getNumericValue(from: salaryAmount) else { return }
        dataManager.setSalaryForMonth(year: selectedYear, month: selectedMonth, amount: amount)
    }
    
    private func formatAmountInput() {
        // Remove all non-numeric characters except decimal point
        let cleanedInput = salaryAmount.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        
        // Convert to number and format with commas
        if let number = Double(cleanedInput) {
            let formatted = formatNumberWithCommas(number)
            if formatted != salaryAmount {
                salaryAmount = formatted
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
