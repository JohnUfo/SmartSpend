# SmartSpend - Intelligent Expense Tracker

SmartSpend is a comprehensive iOS expense tracking application built with SwiftUI that combines intelligent expense management with advanced analytics, smart learning capabilities, and seamless data import functionality.

## 🌟 Key Features

### 💰 **Smart Expense Management**
- **Intuitive Expense Entry**: Quick and easy expense logging with category selection
- **Smart Learning System**: Automatically learns your spending patterns from the last 3 months and suggests frequently used amounts and categories
- **Multi-Currency Support**: Full support for USD, UZS, and RUBL currencies with proper formatting
- **Monthly Salary System**: Set different salaries for each month to accurately track your budget
- **Custom Categories**: 8 predefined expense categories with visual icons and color coding
- **Editable Expenses**: Swipe-to-edit and delete expenses with 30-day soft-delete recovery

### 📊 **Advanced Analytics**
- **Comprehensive Dashboard**: Real-time overview of your spending patterns and budget status
- **Time-based Analysis**: Filter expenses by week, month, or custom date ranges
- **Category Insights**: Detailed breakdown of spending by category with trend analysis
- **Monthly Comparisons**: Compare current month spending with previous periods
- **Spending Trends**: Visual charts and graphs for spending analysis

### 🎯 **Budget & Goal Management**
- **Category Budgets**: Set spending limits for individual expense categories
- **Smart Budget Suggestions**: AI-powered budget recommendations based on spending history
- **Spending Goals**: Create and track savings goals with progress visualization
- **Budget Alerts**: Automatic notifications when approaching spending limits

### 🔄 **Recurring Expenses**
- **Automated Tracking**: Set up recurring expenses for subscriptions, bills, and regular payments
- **Flexible Scheduling**: Support for daily, weekly, bi-weekly, monthly, quarterly, and yearly recurrence
- **Smart Notifications**: Get notified about due and overdue recurring expenses
- **Automatic Processing**: Expenses are automatically created based on your recurring schedule

### 📤 **Data Management & Import**
- **CSV Import**: Import expenses from Notion, Excel, or any CSV file with automatic format detection
- **Smart Category Mapping**: Automatically maps common category names (e.g., "Others" → "Other")
- **Multiple Export Formats**: Export your data in CSV, JSON, or PDF formats
- **Selective Export**: Choose specific data types and date ranges for export
- **Data Recovery**: 30-day recovery system for deleted expenses with countdown timer

### 🎨 **User Experience**
- **iOS Design Compliance**: Follows Apple's Human Interface Guidelines
- **Intuitive Navigation**: Clean 5-tab interface for easy access to all features
- **Custom Gestures**: Swipe-to-delete functionality with visual feedback
- **Dark Mode Ready**: Optimized for both light and dark appearances
- **Smart Suggestions**: Auto-complete expense titles and suggest amounts/categories

## 🧠 Smart Learning System

SmartSpend includes an advanced **Smart Learning Algorithm** that makes expense tracking more efficient by learning from your behavior:

### How It Works
1. **Pattern Recognition**: The system analyzes your expense entries from the last 3 months
2. **Frequency Tracking**: Tracks the most frequently used price-category combinations for each expense title
3. **Intelligent Suggestions**: When you start typing an expense title, SmartSpend suggests the most commonly used amount and category
4. **Continuous Learning**: The system continuously improves suggestions based on your usage patterns
5. **Performance Optimized**: Rebuilds patterns every 10 expenses for optimal performance

### Smart Features
- **Auto-completion**: Expense titles auto-complete based on your history
- **Price Suggestions**: Most frequently used amounts for specific expense types
- **Category Prediction**: Automatically suggests the most likely category
- **One-tap Entry**: Use suggested combinations with a single tap
- **Similarity Matching**: Uses Levenshtein distance for fuzzy matching of expense titles

### Learning Requirements
- The Smart Suggest feature becomes available after you have:
  - At least 3 months of expense history
  - Minimum of 100 recorded expenses
- This ensures accurate and meaningful suggestions

## 📥 Data Import Feature

SmartSpend supports importing expenses from external sources:

### Supported Formats
- **Notion CSV Export**: Automatically detects and parses Notion expense exports
- **Generic CSV**: Supports any CSV file with standard expense columns
- **Custom Formats**: Flexible parsing for various CSV structures

### Import Process
1. **File Selection**: Choose your CSV file from Files app or iCloud Drive
2. **Format Detection**: App automatically detects the CSV format (Notion, SmartSpend, or Custom)
3. **Preview**: Review the data before importing
4. **Smart Mapping**: Automatic category name mapping (e.g., "Others" → "Other")
5. **Import**: Bulk import with detailed error reporting

### Supported Category Mappings
- **Food**: `food`, `restaurant`, `dining`, `groceries`, `meal`, `cafe`
- **Transportation**: `transport`, `transportation`, `uber`, `lyft`, `gas`, `fuel`, `taxi`, `bus`, `metro`, `subway`
- **Shopping**: `shopping`, `clothes`, `fashion`, `retail`, `store`, `market`
- **Entertainment**: `entertainment`, `movie`, `game`, `fun`, `cinema`, `theater`, `concert`
- **Healthcare**: `health`, `healthcare`, `medical`, `pharmacy`, `doctor`, `hospital`
- **Bills**: `bills`, `utilities`, `electricity`, `rent`, `home`, `house`, `apartment`
- **Education**: `education`, `school`, `course`, `book`, `university`, `college`, `study`
- **Other**: `other`, `others`, `misc`, `miscellaneous`, `general`, `personal`

## 🚀 Getting Started

### Prerequisites
- iOS 18.5 or later
- Xcode 16.0 or later
- Swift 5.9 or later

### Installation
1. Clone the repository:
```bash
git clone https://github.com/JohnUfo/SmartSpend.git
cd SmartSpend
```

2. Open the project in Xcode:
```bash
open SmartSpend.xcodeproj
```

3. Build and run the project on your iOS device or simulator.

## 📱 Usage Guide

### Adding Your First Expense
1. Tap the "+" button on the dashboard
2. Enter the expense title, amount, and select a category
3. Choose the date (defaults to today)
4. Tap "Save" to record the expense

### Importing Data from CSV
1. Go to Settings → Import Data
2. Tap "Select CSV File" and choose your file
3. Review the preview to ensure data is correctly parsed
4. Tap "Import" to add all expenses to your app
5. Check the console logs for detailed import results

### Setting Up Monthly Salaries
1. Go to Settings → Monthly Salaries
2. Select any month and year (past, present, or future)
3. Enter your salary amount for that specific month
4. Use the "Go to Current Month" button to quickly navigate to the current month
5. Use "Load Current Amount" to copy existing salary for editing
6. Repeat for each month you want to track

### Setting Up Budgets
1. Go to Settings → Budget & Goals
2. Tap "Add Budget" to create category-specific budgets
3. Set your spending limits and enable budget tracking
4. Use "Suggest Budgets" for AI-powered recommendations

### Creating Recurring Expenses
1. Navigate to the "Recurring" tab
2. Tap "+" to add a new recurring expense
3. Set the recurrence pattern (daily, weekly, monthly, etc.)
4. Configure start/end dates and activation status

### Exporting Your Data
1. Go to Settings → Export Data
2. Select the data types you want to export
3. Choose your preferred format (CSV, JSON, PDF)
4. Set date range if needed
5. Tap "Export" and share the file

## 🏗️ Architecture

SmartSpend is built using modern iOS development practices:

- **SwiftUI**: Declarative UI framework for modern iOS interfaces
- **MVVM Pattern**: Clean separation of concerns with ObservableObject
- **UserDefaults**: Persistent local storage for user data
- **Combine Framework**: Reactive programming for data flow
- **Swift Package Manager**: Dependency management

### Project Structure
```
SmartSpend/
├── Models/           # Data models and business logic
├── Views/            # SwiftUI views and UI components
├── DataManager/      # Data persistence and management
├── Utils/            # Utility classes and extensions
│   └── DataImporter.swift  # CSV import functionality
└── Assets.xcassets/  # App icons and visual assets
```

## 🔧 Technical Details

### Data Models
- **Expense**: Core expense data with category, amount, and date
- **RecurringExpense**: Automated recurring expense definitions
- **CategoryBudget**: Budget limits for expense categories
- **SpendingGoal**: Savings goals with progress tracking
- **LearnedPattern**: Smart learning data for suggestions
- **MonthlySalary**: Month-specific salary tracking

### Smart Learning Algorithm
The learning system uses a frequency-based approach:
1. **Pattern Storage**: Each expense title stores multiple price-category combinations
2. **Frequency Counting**: Tracks how often each combination is used
3. **Suggestion Ranking**: Returns the most frequently used combination
4. **Continuous Updates**: Patterns are updated with each new expense
5. **3-Month Window**: Only considers expenses from the last 3 months for relevance

### Data Import System
- **Multi-format Support**: Handles various CSV formats and encodings
- **Error Handling**: Detailed error reporting for failed imports
- **Category Mapping**: Automatic mapping of common category variations
- **Thread Safety**: Proper main thread handling for UI updates

---

**SmartSpend** - Making expense tracking intelligent and effortless! 🎯💰