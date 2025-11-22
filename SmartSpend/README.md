# 💰 SmartSpend

A powerful iOS expense tracking and budget management app built with SwiftUI.

## 📱 Features

### Core Features
- **📊 Expense Tracking** - Track your daily expenses with custom categories
- **💰 Budget Management** - Set and monitor budgets by category and time period
- **📈 Analytics & Insights** - Visualize spending trends with beautiful charts
- **🎯 Spending Goals** - Set financial goals and track your progress
- **🔄 Recurring Expenses** - Manage subscriptions and regular payments
- **🎨 Custom Categories** - Create personalized expense categories with icons and colors

### Advanced Features
- **🏆 Gamification System** - Unlock achievements for good financial habits
- **📤 Data Export/Import** - Export your financial data in multiple formats
- **🔗 Notion Integration** - Sync your expenses with Notion
- **🌍 Multi-language Support** - Localized interface
- **🌓 Dark Mode** - Optimized for both light and dark appearances

## 🛠️ Technical Stack

- **Language:** Swift
- **Framework:** SwiftUI
- **Architecture:** MVVM with Observation Framework
- **Data Persistence:** SwiftData
- **Minimum iOS Version:** iOS 17.0+
- **Platform Support:** iOS, iPadOS

## 📂 Project Structure

```
SmartSpend/
├── SmartSpendApp.swift          # Main app entry point
├── Views/
│   ├── ContentView.swift        # Root view with initialization
│   ├── MainTabView.swift        # Tab-based navigation
│   ├── DashboardView.swift      # Main dashboard with overview
│   ├── ExpensesView.swift       # Expense list and management
│   ├── AnalyticsView.swift      # Charts and insights
│   └── SettingsView.swift       # App settings and preferences
├── Models/
│   └── DataManager.swift        # Core data management with SwiftData
├── Features/
│   ├── Gamification.swift       # Achievement system
│   ├── NotionIntegration.swift  # Notion API integration
│   ├── RecurringExpenses/       # Recurring expense management
│   └── CategoryManagement/      # Custom category system
└── Utilities/
    ├── DataExporter.swift       # Export functionality
    ├── DataImporter.swift       # Import functionality
    └── Extensions/              # Swift extensions

```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- macOS 14.0+ (for development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YourUsername/SmartSpend.git
cd SmartSpend
```

2. Open the project in Xcode:
```bash
open SmartSpend.xcodeproj
```

3. Build and run the project (⌘ + R)

## 💡 Usage

### Adding an Expense
1. Tap the **+** button in the navigation bar
2. Enter expense details (amount, category, description)
3. Add optional notes or tags
4. Tap "Save"

### Setting a Budget
1. Navigate to the **Settings** tab
2. Select "Budget Management"
3. Choose a category and time period
4. Set your budget limit

### Viewing Analytics
1. Open the **Analytics** tab
2. View spending breakdown by category
3. Analyze trends over different time periods
4. Track progress towards your goals

## 🔐 Privacy

SmartSpend is designed with privacy in mind:
- All data is stored locally on your device using SwiftData
- No personal information is collected or transmitted
- Optional cloud sync uses your own iCloud account
- Notion integration requires explicit user authorization

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is available for personal and educational use. Please contact the author for commercial licensing.

## 👤 Author

**Umidjon Tursunov**

## 🙏 Acknowledgments

- Built with Apple's SwiftUI framework
- Uses SF Symbols for iconography
- Inspired by modern personal finance apps

## 📊 Roadmap

- [ ] Add Apple Watch companion app
- [ ] Widget support for iOS home screen
- [ ] Advanced reporting with PDF export
- [ ] Multi-currency support
- [ ] Family sharing features
- [ ] Integration with banking APIs
- [ ] AI-powered spending insights

---

**Made with ❤️ using SwiftUI**
