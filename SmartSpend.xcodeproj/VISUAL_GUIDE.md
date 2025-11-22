# Visual Guide: Where to Click in Xcode

## Finding File Inspector (Target Membership)

```
Xcode Window Layout:
╔═══════════════════╦═══════════════════════════════╦═══════════════════╗
║ Project Navigator ║                               ║ File Inspector    ║
║ (Left Sidebar)    ║   Code Editor (Middle)        ║ (Right Sidebar)   ║
║                   ║                               ║                   ║
║ 📁 SmartSpend     ║   import XCTest               ║ 📋 Identity       ║
║   📁 Tests        ║   @testable import SmartSpend ║                   ║
║     📄 Tests.swift║                               ║ 🎯 Target         ║
║       ↑           ║   class Tests: XCTestCase {   ║    Membership     ║
║   Click here!     ║     func test() { }           ║                   ║
║                   ║   }                           ║ [ ] SmartSpend    ║
║                   ║                               ║ [✓] Tests Target  ║
╚═══════════════════╩═══════════════════════════════╩═══════════════════╝
                                                            ↑
                                                        Fix this!
```

## How to Open File Inspector

**Option 1:** Press `⌘⌥1` (Command + Option + 1)

**Option 2:** Top-right toolbar → Click the 📁 folder icon

**Option 3:** Menu Bar → View → Inspectors → Show File Inspector

---

## What Target Membership Should Look Like

### ❌ WRONG (Current state - causes errors):
```
SmartSpendTests.swift selected:

Target Membership:
┌─────────────────────────┐
│ [✓] SmartSpend          │ ← WRONG! Remove this checkmark
│ [✓] SmartSpendTests     │ ← This one is OK
│ [ ] SmartSpendUITests   │
└─────────────────────────┘
```

### ✅ CORRECT (What it should be):
```
SmartSpendTests.swift selected:

Target Membership:
┌─────────────────────────┐
│ [ ] SmartSpend          │ ← Unchecked
│ [✓] SmartSpendTests     │ ← Only this checked
│ [ ] SmartSpendUITests   │ ← Unchecked
└─────────────────────────┘
```

---

## Finding Build Phases

```
Xcode Window:
╔═══════════════════════════════════════════════════════════════╗
║ Project Navigator                                             ║
║                                                               ║
║ 📘 SmartSpend (blue icon) ← Click here                        ║
║   📁 SmartSpend                                               ║
║   📁 Tests                                                    ║
╚═══════════════════════════════════════════════════════════════╝

Then in the main panel:
╔═══════════════════════════════════════════════════════════════╗
║ TARGETS                                                       ║
║  📱 SmartSpend       ← Click this (main app target)           ║
║  🧪 SmartSpendTests                                           ║
║  🔍 SmartSpendUITests                                         ║
║                                                               ║
║ Tabs: General | Signing | Resources | Info | Build Settings  ║
║       ▼ Build Phases ◀── Click this tab                       ║
╚═══════════════════════════════════════════════════════════════╝

In Build Phases:
╔═══════════════════════════════════════════════════════════════╗
║ ▼ Compile Sources (30 items)  ◀── Click triangle to expand   ║
║   ├─ SmartSpendApp.swift       ✅ Should be here              ║
║   ├─ Expense.swift             ✅ Should be here              ║
║   ├─ MainTabView.swift         ✅ Should be here              ║
║   ├─ SmartSpendTests.swift     ❌ Should NOT be here - DELETE ║
║   └─ ... more files                                           ║
╚═══════════════════════════════════════════════════════════════╝

To remove a file:
1. Click on it (e.g., SmartSpendTests.swift)
2. Press the minus (-) button below the list
```

---

## The Three Targets Explained

```
╔═══════════════════════════════════════════════════════════════╗
║ 📱 SmartSpend (Main App Target)                               ║
║    Contains: Your app's code                                  ║
║    Should have: All your .swift app files                     ║
║    Should NOT have: Test files                                ║
╚═══════════════════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════════════════╗
║ 🧪 SmartSpendTests (Unit Test Target)                         ║
║    Contains: Unit tests                                       ║
║    Should have: SmartSpendTests.swift                         ║
║    Should NOT have: UI test files or app files                ║
╚═══════════════════════════════════════════════════════════════╝

╔═══════════════════════════════════════════════════════════════╗
║ 🔍 SmartSpendUITests (UI Test Target)                         ║
║    Contains: UI tests                                         ║
║    Should have: SmartSpendUITests.swift                       ║
║    Should NOT have: Unit test files or app files              ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## Quick Reference: What Goes Where

```
File                          → Target(s)
─────────────────────────────────────────────────────────
SmartSpendApp.swift          → SmartSpend only
Expense.swift                → SmartSpend only
MonthlySalary.swift          → SmartSpend only
All View files               → SmartSpend only
All Manager files            → SmartSpend only

SmartSpendTests.swift        → SmartSpendTests only
SmartSpendUITests.swift      → SmartSpendUITests only

.sh script files             → NONE (don't compile these!)
Localizable.strings          → SmartSpend (Copy Bundle Resources)
```

---

## Keyboard Shortcuts Cheatsheet

```
⌘B                → Build
⌘⇧K               → Clean Build Folder
⌘U                → Run Tests
⌘⌥1               → Show File Inspector
⌘A                → Select All
⌘C                → Copy
⌘V                → Paste
⌘S                → Save
⌘Q                → Quit Xcode
```

---

This guide helps you visualize exactly where to click and what to look for!
