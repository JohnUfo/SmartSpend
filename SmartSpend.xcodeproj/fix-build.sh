#!/bin/bash

# This script helps identify duplicate files in your project

echo "🔍 Searching for duplicate Swift files..."
echo ""

# Find duplicate Expense files
echo "📁 Searching for Expense.swift:"
find . -name "Expense.swift" -type f | grep -v "/\."
echo ""

# Find duplicate LocalizationManager files
echo "📁 Searching for LocalizationManager.swift:"
find . -name "LocalizationManager.swift" -type f | grep -v "/\."
echo ""

# Find duplicate MonthlySalary files
echo "📁 Searching for MonthlySalary.swift:"
find . -name "MonthlySalary.swift" -type f | grep -v "/\."
echo ""

# Find all Swift files and check for duplicates
echo "📊 Checking for any duplicate .swift filenames:"
find . -name "*.swift" -type f | grep -v "/\." | awk -F/ '{print $NF}' | sort | uniq -d
echo ""

echo "✅ Check above for any duplicate files and DELETE them from Finder or Xcode!"
