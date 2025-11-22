//
//  SmartSpendTests.swift
//  SmartSpendTests
//
//  Created by Umidjon Tursunov on 23/08/2025.
//

import Testing
import Foundation
@testable import SmartSpend

@Suite("SmartSpend Tests")
struct SmartSpendTests {

    @Test("Example test")
    func example() async throws {
        #expect(true, "This test should pass")
    }

    @Test("Expense creation")
    func expenseCreation() async throws {
        let expense = Expense(
            title: "Test Expense",
            amount: 100.0,
            category: .food,
            date: Date()
        )
        
        #expect(expense.title == "Test Expense")
        #expect(expense.amount == 100.0)
        #expect(expense.category == .food)
        #expect(expense.id != nil)
    }
    
    @Test("Monthly salary creation")
    func monthlySalaryCreation() async throws {
        let salary = MonthlySalary(
            year: 2025,
            month: 11,
            amount: 5000.0,
            currency: .usd
        )
        
        #expect(salary.year == 2025)
        #expect(salary.month == 11)
        #expect(salary.amount == 5000.0)
        #expect(salary.currency == .usd)
        #expect(salary.id != nil)
    }
}
