# SmartSpend v2.2 - Intelligent Expense Tracker with Notion Integration

SmartSpend is a comprehensive iOS expense tracking application built with SwiftUI that combines intelligent expense management with advanced analytics, smart learning capabilities, seamless data import functionality, and powerful Notion integration. Version 2.2 introduces revolutionary auto-sync with Notion, enhanced smart learning, and comprehensive CRUD operations.

## 🌟 Key Features

### 💰 **Smart Expense Management**
- **Intuitive Expense Entry**: Quick and easy expense logging with category selection
- **Smart Learning System**: Automatically learns your spending patterns from the last 3 months and suggests frequently used amounts and categories
- **Multi-Currency Support**: Full support for USD, UZS, and RUBL currencies with proper formatting
- **Monthly Salary System**: Set different salaries for each month to accurately track your budget
- **Custom Categories**: 8 predefined expense categories with visual icons and color coding
- **Editable Expenses**: Swipe-to-edit and delete expenses with 30-day soft-delete recovery
- **Enhanced Delete UI**: Beautiful custom swipe-to-delete with smooth animations and single delete button

### 🔗 **Revolutionary Notion Integration**
- **Auto-Sync System**: Toggle-based auto-sync that only imports expenses created after enabling sync
- **Bidirectional Sync**: Full CRUD operations - Create, Read, Update, Delete expenses between Notion and SmartSpend
- **Smart Filtering**: Only processes changes that occurred after auto-sync was enabled
- **Real-Time Updates**: Checks for changes every 30 seconds when auto-sync is enabled
- **Notion ID Tracking**: Maintains proper relationship between Notion entries and app expenses
- **Safe Operations**: Only affects expenses imported from Notion, preserves local expenses
- **Connection Management**: Easy setup with API key and database ID configuration

### 📅 **Advanced Calendar & Date Selection**
- **Interactive Calendar Picker**: Beautiful iOS-style calendar interface for custom date range selection
- **From/To Date Selection**: Intuitive two-step date selection with "From" and "To" buttons
- **Independent Date Selection**: Each mode shows only its own selected date for clear visual feedback
- **Month Navigation**: Swipe through months with smooth navigation controls
- **Instant Date Selection**: Responsive tap-to-select functionality without lag or gesture conflicts
- **85% Modal Presentation**: Optimized calendar view with perfect height for easy interaction
- **Smart Date Range Application**: Date ranges are applied only when "Done" is pressed for user control

### 📊 **Advanced Analytics**
- **Comprehensive Dashboard**: Real-time overview of your spending patterns and budget status
- **Dynamic Time-based Analysis**: Filter expenses by All Time, This Month, Last Month, or Custom Month
- **Interactive Budget Overview**: Pressable budget card with detailed insights and time period selection
- **Category Breakdown**: Dynamic spending breakdown that updates based on selected time period
- **Spending Trends**: Daily and weekly average spending indicators with trend analysis
- **Enhanced Charts**: Improved spending trends visualization with better number formatting (6M instead of 6.0E6)

### 🎯 **Budget & Goal Management**
- **Category Budgets**: Set spending limits for individual expense categories
- **Smart Budget Suggestions**: AI-powered budget recommendations based on spending history
- **Spending Goals**: Create and track savings goals with progress visualization and completion alerts
- **Budget Alerts**: Automatic notifications when approaching spending limits
- **Immediate Updates**: Budget suggestions and resets update instantly without requiring page navigation

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
- **Notion Sync Integration**: Seamless integration with CSV import - clears sync date to prevent duplicates

### 🎨 **User Experience**
- **iOS Design Compliance**: Follows Apple's Human Interface Guidelines with enhanced iOS 17+ compatibility
- **Intuitive Navigation**: Clean 5-tab interface for easy access to all features
- **Enhanced Gestures**: Improved swipe-to-delete functionality with better scrolling support on physical devices
- **Dark Mode Ready**: Optimized for both light and dark appearances
- **Smart Suggestions**: Auto-complete expense titles and suggest amounts/categories
- **Search Functionality**: Enhanced expense search with keyboard dismissal and clear button
- **Time Period Filtering**: iOS-style time period selection with beautiful grid layout

## 🆕 What's New in v2.2

### 🔗 **Revolutionary Notion Integration**
- **Auto-Sync Toggle**: User-controlled auto-sync that only imports expenses created after enabling
- **Bidirectional CRUD Operations**: Complete Create, Read, Update, Delete functionality
- **Smart Change Detection**: Only processes changes that occurred after auto-sync was enabled
- **Real-Time Monitoring**: 30-second interval checks for new, updated, or deleted expenses
- **Notion ID Tracking**: Maintains proper relationships between Notion entries and app expenses
- **Safe Deletion**: Only deletes expenses that were originally imported from Notion
- **Connection Management**: Easy setup with API key and database ID configuration
- **Sync Status Display**: Real-time status updates showing sync progress and results

### 🧠 **Enhanced Smart Learning System**
- **Silent Operation**: Removed debug console output for cleaner user experience
- **Performance Optimized**: Improved pattern rebuilding and suggestion algorithms
- **Better Pattern Matching**: Enhanced similarity scoring for more accurate suggestions
- **Reduced Console Clutter**: Clean operation without verbose logging during CSV import

### 🎨 **UI/UX Improvements**
- **Single Delete Button**: Fixed duplicate delete buttons issue with beautiful custom swipe-to-delete
- **Smooth Animations**: Enhanced delete button animations with spring effects
- **Better Gesture Handling**: Improved swipe recognition that distinguishes between horizontal swipes and vertical scrolls
- **Tap to Dismiss**: Easy dismissal of delete buttons with tap gestures

### 🔧 **Technical Enhancements**
- **Swift 6 Compatibility**: Fixed concurrency issues and improved code structure
- **Better Error Handling**: Enhanced error management for Notion API operations
- **Optimized Data Filtering**: Improved performance for large expense datasets
- **Memory Management**: Better resource handling and reduced memory usage

### 🐛 **Bug Fixes & Stability**
- **Fixed Duplicate Delete Buttons**: Resolved issue with multiple delete buttons appearing
- **Notion Sync Issues**: Fixed problems with historical data flooding during CSV import
- **Concurrency Fixes**: Resolved Swift 6 concurrency warnings and errors
- **Data Consistency**: Improved reliability of expense tracking and sync operations

## 🆕 What's New in v2.1

### 📅 **Revolutionary Calendar Picker**
- **Interactive Calendar Interface**: Beautiful, native iOS-style calendar for custom date selection
- **Two-Step Date Selection**: Clear "From" and "To" button workflow for intuitive date range selection
- **Independent Visual Feedback**: Each selection mode shows only its own selected date for clarity
- **Month Navigation**: Smooth month-to-month navigation with intuitive controls
- **Optimized Modal Presentation**: 85% height modal for perfect balance of visibility and usability
- **User-Controlled Application**: Date ranges are applied only when user presses "Done" for full control

### 🎨 **Enhanced iOS Design**
- **Native iOS Styling**: Complete redesign following Apple's Human Interface Guidelines
- **System Colors**: Proper use of system colors for light/dark mode compatibility
- **Modern Typography**: iOS-standard font weights and sizes throughout the interface
- **Improved Visual Hierarchy**: Better spacing, shadows, and visual depth
- **Responsive Interactions**: Instant feedback and smooth animations

### 🔧 **Performance Improvements**
- **Eliminated Gesture Conflicts**: Removed complex gesture handling that caused selection lag
- **Simplified Date Selection**: Streamlined tap-to-select functionality for instant response
- **Optimized State Management**: Cleaner state handling for better performance
- **Reduced Memory Usage**: More efficient data structures and algorithms

### 🐛 **Bug Fixes & Stability**
- **Fixed System Symbol Issues**: Resolved missing system symbols and icon conflicts
- **Eliminated ForEach ID Conflicts**: Fixed duplicate ID issues in calendar grid and day headers
- **Improved Error Handling**: Better compilation error resolution and code structure
- **Enhanced Data Consistency**: More reliable date range filtering and expense management

## 🆕 What's New in v2.0

### 🎯 **Enhanced Budget Management**
- **Interactive Budget Overview**: Tap the budget card to open a detailed popup with comprehensive insights
- **Time Period Selection**: Choose from All Time, This Month, Last Month, or Custom Month to filter all data
- **Dynamic Data Updates**: All dashboard components update in real-time based on selected time period
- **Shared State Management**: Consistent time period selection across all views

### 📊 **Improved Analytics**
- **Enhanced Spending Trends**: Better chart visualization with improved number formatting
- **Category Breakdown**: Dynamic category spending that updates based on time period selection
- **Daily/Weekly Averages**: Quick insights into spending patterns with trend indicators
- **Removed Redundant Features**: Streamlined analytics by removing Quarter/Year timeframes and Budget Alerts section

### 🎨 **UI/UX Improvements**
- **iOS 17+ Compatibility**: Enhanced gesture handling and improved scrolling on physical devices
- **Better Search Experience**: Keyboard auto-dismissal and clear search button
- **Improved Expense Management**: Enhanced swipe-to-delete with better gesture recognition
- **Material Design**: Enhanced visual depth with improved shadows and backgrounds

### 🔧 **Technical Enhancements**
- **Shared DataManager State**: Centralized time period management for consistent data filtering
- **Performance Optimizations**: Improved data filtering and calculation methods
- **Better Error Handling**: Enhanced compilation error fixes and code structure
- **Equatable Conformance**: Added proper protocol conformance for better data management

## 🔗 Notion Integration Guide

### Setup Instructions
1. **Create Notion Integration**:
   - Go to [notion.so/my-integrations](https://notion.so/my-integrations)
   - Create a new integration
   - Copy the API key

2. **Share Your Database**:
   - Open your Notion expense database
   - Click "Share" and add your integration
   - Copy the database ID from the URL

3. **Configure in SmartSpend**:
   - Go to Settings → Notion Integration
   - Enter your API key and database ID
   - Test the connection

### Auto-Sync Features
- **Toggle Control**: Enable/disable auto-sync with a simple toggle switch
- **Smart Filtering**: Only imports expenses created after auto-sync was enabled
- **Real-Time Updates**: Checks for changes every 30 seconds
- **Bidirectional Sync**: Handles creates, updates, and deletes in both directions

### Database Requirements
Your Notion database should have these properties:
- **Title/Expense**: The expense name
- **Amount/Price**: The expense amount (number)
- **Category**: The expense category (select)
- **Date**: The expense date (date)

### Sync Behavior
- **New Expenses**: Automatically added to SmartSpend when created in Notion
- **Updated Expenses**: Automatically updated in SmartSpend when modified in Notion
- **Deleted Expenses**: Automatically removed from SmartSpend when deleted from Notion
- **Safe Operations**: Only affects expenses imported from Notion, preserves local expenses

## 🧠 Smart Learning System

SmartSpend includes an advanced **Smart Learning Algorithm** that makes expense tracking more efficient by learning from your behavior:

### How It Works
1. **Pattern Recognition**: The system analyzes your expense entries from the last 3 months
2. **Frequency Tracking**: Tracks the most frequently used price-category combinations for each expense title
3. **Intelligent Suggestions**: When you start typing an expense title, SmartSpend suggests the most commonly used amount and category
4. **Continuous Learning**: The system continuously improves suggestions based on your usage patterns
5. **Performance Optimized**: Rebuilds patterns every 10 expenses for optimal performance
6. **Silent Operation**: Clean operation without verbose console logging

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
6. **Notion Sync Integration**: Automatically clears Notion sync date to prevent duplicates

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

### Setting Up Notion Integration
1. Go to Settings → Notion Integration
2. Enter your Notion API key and database ID
3. Test the connection to ensure it's working
4. Toggle on "Auto-Sync" to start automatic synchronization
5. Only expenses created after enabling auto-sync will be imported

### Using the Interactive Budget Overview
1. Tap the "Budget Overview" card on the dashboard
2. Select your desired time period (All Time, This Month, Last Month, Custom Month)
3. View detailed budget insights including progress, spent/remaining amounts, and category breakdown
4. All dashboard data will update automatically based on your selection

### Using the Enhanced Calendar Picker
1. Select "Custom Month" from the time period filter
2. The calendar picker will open with a beautiful iOS-style interface
3. **Select Start Date**: Tap the "From" button (highlighted in blue) and select your start date
4. **Select End Date**: Tap the "To" button and select your end date
5. **Visual Feedback**: Each mode shows only its own selected date for clear visual feedback
6. **Apply Range**: Press "Done" to apply the date range and filter your expenses
7. **Month Navigation**: Use the arrow buttons to navigate between months if needed

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
4. Use "Suggest Budgets" for AI-powered recommendations (updates immediately)
5. Use "Reset All Budgets" to clear all budgets (updates immediately)

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

### Managing Expenses with Swipe Actions
1. **Swipe Left**: Reveals a beautiful red delete button with smooth animations
2. **Tap Delete**: Confirms deletion with spring animation
3. **Tap Expense**: Opens edit view when delete button is not visible
4. **Tap Background**: Dismisses delete button

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
├── Models/                    # Data models and business logic
│   ├── NotionIntegration.swift  # Notion API integration
│   └── LearnedPattern.swift     # Smart learning algorithms
├── Views/                     # SwiftUI views and UI components
│   ├── NotionIntegrationView.swift  # Notion setup and sync UI
│   └── ExpenseRowView.swift        # Enhanced expense row with custom delete
├── DataManager/               # Data persistence and management
├── Utils/                     # Utility classes and extensions
│   ├── DataImporter.swift     # CSV import functionality
│   └── ViewExtensions.swift   # Custom view extensions and delete manager
└── Assets.xcassets/           # App icons and visual assets
```

## 🔧 Technical Details

### Data Models
- **Expense**: Core expense data with category, amount, date, and Notion ID tracking
- **RecurringExpense**: Automated recurring expense definitions
- **CategoryBudget**: Budget limits for expense categories (with Equatable conformance)
- **SpendingGoal**: Savings goals with progress tracking and completion alerts
- **LearnedPattern**: Smart learning data for suggestions
- **MonthlySalary**: Month-specific salary tracking
- **TimePeriod**: Enum for time-based filtering (All Time, This Month, Last Month, Custom Month)
- **NotionIntegrationManager**: Complete Notion API integration with auto-sync capabilities

### Notion Integration System
- **API Communication**: RESTful API calls to Notion with proper authentication
- **Auto-Sync Engine**: Timer-based sync with smart change detection
- **CRUD Operations**: Complete Create, Read, Update, Delete functionality
- **ID Tracking**: Maintains Notion ID relationships for accurate sync
- **Error Handling**: Comprehensive error management for API operations
- **Connection Management**: Easy setup and testing of Notion connections

### Smart Learning Algorithm
The learning system uses a frequency-based approach:
1. **Pattern Storage**: Each expense title stores multiple price-category combinations
2. **Frequency Counting**: Tracks how often each combination is used
3. **Suggestion Ranking**: Returns the most frequently used combination
4. **Continuous Updates**: Patterns are updated with each new expense
5. **3-Month Window**: Only considers expenses from the last 3 months for relevance
6. **Silent Operation**: Clean operation without verbose logging

### Data Import System
- **Multi-format Support**: Handles various CSV formats and encodings
- **Error Handling**: Detailed error reporting for failed imports
- **Category Mapping**: Automatic mapping of common category variations
- **Thread Safety**: Proper main thread handling for UI updates
- **Notion Integration**: Automatic sync date clearing to prevent duplicates

### Time Period Filtering System
- **Shared State Management**: Centralized time period selection across all views
- **Dynamic Data Filtering**: Real-time expense filtering based on selected time period
- **Salary Integration**: Appropriate salary calculation for each time period
- **Performance Optimized**: Efficient filtering algorithms for large datasets

### Calendar Picker System
- **Interactive Calendar Interface**: Native iOS-style calendar with month navigation
- **Two-Step Selection Process**: Independent "From" and "To" date selection modes
- **Visual State Management**: Clear visual feedback for each selection mode
- **Modal Presentation**: 85% height modal with optimal user experience
- **Gesture-Free Interaction**: Simple tap-to-select without complex gesture conflicts
- **Date Range Validation**: Smart handling of date order and range application

### Enhanced Delete System
- **Custom Swipe-to-Delete**: Beautiful red delete button with smooth animations
- **Single Button Design**: Eliminated duplicate delete buttons issue
- **Gesture Recognition**: Smart detection of horizontal vs vertical gestures
- **Spring Animations**: Smooth spring effects for delete button appearance/disappearance
- **Tap to Dismiss**: Easy dismissal with tap gestures

---

**SmartSpend v2.2** - Making expense tracking intelligent and effortless with powerful Notion integration! 🎯💰🔗

*Enhanced with revolutionary auto-sync, bidirectional CRUD operations, and seamless Notion integration.*