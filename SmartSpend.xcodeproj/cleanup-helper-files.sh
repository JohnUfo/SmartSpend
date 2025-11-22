#!/bin/bash

echo "🗑️  Cleaning up helper files..."
echo ""

cd /Users/umidjontursunov/Desktop/SmartSpend

# List of files to remove
FILES_TO_REMOVE=(
    "fix-duplicates.sh"
    "fix-duplicate-errors.sh"
    "complete-fix.sh"
    "fix-test-targets.sh"
    "FIX_DUPLICATES_GUIDE.md"
    "FIX_BUILD_ERRORS_COMPLETE.md"
    "FIX_TEST_TARGET_MEMBERSHIP.md"
    "FIX_ALL_BUILD_ERRORS.md"
    "QUICK_FIX_README.md"
    "ULTIMATE_TEST_FIX.md"
    "EMERGENCY_FIX_CARD.txt"
    "SmartSpendTests_FIXED.swift"
    "SmartSpendUITests_FIXED.swift"
    "SmartSpendUITests_NEW.swift"
)

echo "Files to be removed:"
for file in "${FILES_TO_REMOVE[@]}"; do
    if [ -f "$file" ]; then
        echo "  - $file"
    fi
done

echo ""
read -p "Do you want to delete these files? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    for file in "${FILES_TO_REMOVE[@]}"; do
        if [ -f "$file" ]; then
            rm "$file"
            echo "  ✅ Deleted: $file"
        fi
    done
    
    # Also remove this cleanup script itself
    echo "  ✅ Cleaning complete!"
    echo ""
    echo "Note: You may need to remove these from Xcode's Project Navigator too."
    echo "After cleanup, this script will self-delete..."
    rm -- "$0"
else
    echo "Cleanup cancelled."
fi
