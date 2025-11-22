# Contributing to SmartSpend

Thank you for your interest in contributing to SmartSpend! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues
1. **Search existing issues** first to avoid duplicates
2. **Use the issue template** when creating new issues
3. **Provide detailed information**:
   - iOS version
   - Device model
   - Steps to reproduce
   - Expected vs actual behavior
   - Screenshots if applicable

### Suggesting Features
1. **Check the roadmap** to see if the feature is already planned
2. **Create a detailed feature request** with:
   - Clear description of the feature
   - Use cases and benefits
   - Potential implementation approach
   - UI/UX considerations

### Code Contributions

#### Getting Started
1. **Fork the repository**
2. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Set up the development environment**:
   - Xcode 16.0 or later
   - iOS 18.5+ deployment target
   - Swift 5.9+

#### Development Guidelines

##### Code Style
- Follow **Swift API Design Guidelines**
- Use **SwiftLint** for consistent formatting
- Maintain **iOS Human Interface Guidelines** compliance
- Write **clear, descriptive variable names**
- Add **meaningful comments** for complex logic

##### Architecture Patterns
- Follow **MVVM pattern** with SwiftUI
- Use **ObservableObject** for data management
- Implement **proper separation of concerns**
- Keep **views lightweight** and focused

##### File Organization
```
SmartSpend/
├── Models/           # Data models only
├── Views/            # SwiftUI views
├── DataManager/      # Data persistence logic
├── Utils/            # Utility classes and extensions
└── Tests/            # Unit and UI tests
```

##### Naming Conventions
- **Files**: PascalCase (e.g., `ExpenseRowView.swift`)
- **Classes/Structs**: PascalCase (e.g., `DataManager`)
- **Variables/Functions**: camelCase (e.g., `totalExpenses`)
- **Constants**: camelCase (e.g., `defaultCurrency`)
- **Enums**: PascalCase with camelCase cases

#### Code Quality Standards

##### SwiftUI Best Practices
```swift
// ✅ Good: Clean, focused view
struct ExpenseRowView: View {
    let expense: Expense
    @ObservedObject private var dataManager = DataManager.shared
    
    var body: some View {
        HStack {
            categoryIcon
            expenseDetails
            Spacer()
            amountText
        }
        .padding()
    }
    
    private var categoryIcon: some View {
        Image(systemName: expense.category.icon)
            .foregroundColor(expense.category.color)
    }
}

// ❌ Avoid: Monolithic views with complex logic
```

##### Data Management
```swift
// ✅ Good: Clean data operations
@Published var expenses: [Expense] = []

func addExpense(_ expense: Expense) {
    expenses.append(expense)
    saveExpenses()
    updateLearnedPatterns(for: expense)
}

// ❌ Avoid: Direct UserDefaults access in views
```

##### Error Handling
```swift
// ✅ Good: Proper error handling
func loadExpenses() {
    guard let data = UserDefaults.standard.data(forKey: expensesKey) else {
        print("No expense data found")
        return
    }
    
    do {
        expenses = try JSONDecoder().decode([Expense].self, from: data)
    } catch {
        print("Failed to decode expenses: \(error)")
        expenses = []
    }
}
```

#### Testing Requirements
- **Unit tests** for data models and business logic
- **UI tests** for critical user flows
- **Accessibility tests** for VoiceOver compatibility
- **Performance tests** for data-heavy operations

#### Documentation Standards
- **Document public APIs** with clear descriptions
- **Add inline comments** for complex algorithms
- **Update README.md** for new features
- **Include code examples** in documentation

## 🔄 Pull Request Process

### Before Submitting
1. **Test thoroughly** on device and simulator
2. **Run all tests** and ensure they pass
3. **Check for memory leaks** using Instruments
4. **Verify accessibility** with VoiceOver
5. **Update documentation** as needed

### PR Guidelines
1. **Use descriptive titles** and clear descriptions
2. **Reference related issues** using keywords (fixes #123)
3. **Include screenshots** for UI changes
4. **Add tests** for new functionality
5. **Keep PRs focused** - one feature per PR

### Review Process
1. **Automated checks** must pass (build, tests, linting)
2. **Code review** by maintainers
3. **Testing** on multiple devices/iOS versions
4. **Documentation review** for completeness
5. **Final approval** and merge

## 🎯 Development Focus Areas

### High Priority
- **Performance optimization**
- **Accessibility improvements**
- **iOS design compliance**
- **Data persistence reliability**
- **User experience enhancements**

### Feature Categories
- **Core Functionality**: Expense management, categorization
- **Smart Features**: Learning algorithms, suggestions
- **Analytics**: Charts, insights, trends
- **Data Management**: Export, backup, sync
- **User Interface**: Design improvements, animations

## 🧪 Testing Guidelines

### Unit Testing
```swift
import XCTest
@testable import SmartSpend

class DataManagerTests: XCTestCase {
    var dataManager: DataManager!
    
    override func setUp() {
        super.setUp()
        dataManager = DataManager()
    }
    
    func testAddExpense() {
        let expense = Expense(title: "Test", amount: 10.0, category: .food)
        dataManager.addExpense(expense)
        
        XCTAssertEqual(dataManager.expenses.count, 1)
        XCTAssertEqual(dataManager.expenses.first?.title, "Test")
    }
}
```

### UI Testing
```swift
import XCTest

class SmartSpendUITests: XCTestCase {
    func testAddExpenseFlow() {
        let app = XCUIApplication()
        app.launch()
        
        // Navigate to add expense
        app.buttons["plus"].tap()
        
        // Fill expense details
        app.textFields["titleField"].tap()
        app.textFields["titleField"].typeText("Coffee")
        
        app.textFields["amountField"].tap()
        app.textFields["amountField"].typeText("5.50")
        
        // Save expense
        app.buttons["Save"].tap()
        
        // Verify expense was added
        XCTAssertTrue(app.staticTexts["Coffee"].exists)
    }
}
```

## 📱 Device Testing

### Required Testing
- **iPhone**: 15, 16 series (various sizes)
- **iPad**: Air, Pro (both orientations)
- **iOS Versions**: 18.5, 18.6, latest beta
- **Accessibility**: VoiceOver, Dynamic Type
- **Performance**: Memory usage, battery impact

### Testing Scenarios
1. **New user onboarding**
2. **Large dataset performance** (1000+ expenses)
3. **Network connectivity** (export features)
4. **Background/foreground transitions**
5. **Memory pressure** situations

## 🎨 Design Guidelines

### iOS Design Principles
- **Clarity**: Clear visual hierarchy and readable text
- **Deference**: UI defers to content
- **Depth**: Layered interface with realistic motion

### Color and Typography
- Use **system colors** for consistency
- Support **Dark Mode** throughout
- Implement **Dynamic Type** for accessibility
- Maintain **sufficient contrast** ratios

### Animation and Interaction
- Use **standard iOS animations**
- Implement **haptic feedback** appropriately
- Ensure **60fps performance**
- Follow **iOS gesture conventions**

## 📚 Resources

### Apple Documentation
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Accessibility Guidelines](https://developer.apple.com/accessibility/)

### Community Resources
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [SwiftUI Best Practices](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
- [iOS Performance Guidelines](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/EnergyGuide-iOS/)

## 🏆 Recognition

### Contributors
All contributors will be recognized in:
- **README.md** contributors section
- **App Store** credits (for significant contributions)
- **Release notes** acknowledgments

### Contribution Types
- 🐛 **Bug fixes**
- ✨ **New features**
- 📚 **Documentation**
- 🎨 **Design improvements**
- ⚡ **Performance enhancements**
- 🧪 **Testing improvements**

## 📞 Getting Help

### Communication Channels
- **GitHub Issues**: Bug reports and feature requests
- **Discussions**: General questions and ideas
- **Email**: Direct contact for sensitive issues

### Response Times
- **Bug reports**: 24-48 hours
- **Feature requests**: 1 week
- **Pull requests**: 3-5 business days

---

Thank you for contributing to SmartSpend! Together, we're building the best expense tracking experience for iOS users. 🚀💰
