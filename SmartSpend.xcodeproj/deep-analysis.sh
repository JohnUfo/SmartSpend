#!/bin/bash

# Comprehensive script to find and list duplicate Swift files in the project
# This will help identify which files need to be removed

echo "🔍 DEEP ANALYSIS: Finding duplicate files in SmartSpend project"
echo "================================================================"
echo ""

PROJECT_ROOT="/Users/umidjontursunov/Desktop/SmartSpend"

cd "$PROJECT_ROOT" || exit

echo "📁 Project structure:"
find . -name "*.swift" -type f | grep -v "/.build/" | grep -v "/DerivedData/" | sort
echo ""
echo "================================================================"
echo ""

echo "🚨 DUPLICATE FILES ANALYSIS:"
echo ""

# Function to check for duplicates
check_duplicates() {
    local filename=$1
    echo "Checking: $filename"
    find . -name "$filename" -type f | grep -v "/.build/" | grep -v "/DerivedData/"
    echo ""
}

echo "1️⃣ Expense.swift locations:"
check_duplicates "Expense.swift"

echo "2️⃣ LocalizationManager.swift locations:"
check_duplicates "LocalizationManager.swift"

echo "3️⃣ MonthlySalary.swift locations:"
check_duplicates "MonthlySalary.swift"

echo "4️⃣ UserCategory.swift locations:"
check_duplicates "UserCategory.swift"

echo "5️⃣ RecurringExpense.swift locations:"
check_duplicates "RecurringExpense.swift"

echo "================================================================"
echo ""
echo "🔧 RECOMMENDED ACTIONS:"
echo ""
echo "For each file listed MORE THAN ONCE above:"
echo "  1. Keep the one in the organized folder (e.g., Models/)"
echo "  2. DELETE the one at the root level"
echo "  3. In Xcode, remove the deleted file from Build Phases"
echo ""
echo "================================================================"
echo ""

# Find all duplicate filenames (regardless of path)
echo "📊 ALL duplicate filenames in project:"
find . -name "*.swift" -type f | grep -v "/.build/" | grep -v "/DerivedData/" | awk -F/ '{print $NF}' | sort | uniq -d

echo ""
echo "✅ Analysis complete!"
