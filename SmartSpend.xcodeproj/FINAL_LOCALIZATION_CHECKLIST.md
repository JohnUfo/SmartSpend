# 🚨 FINAL CHECKLIST - All Localization Keys for Import/Export

## ✅ Status: Code is CORRECT - Keys just need to be added to localization files!

All the code in `DataImportView.swift` is already properly using `.localized` on every string. The column names like `column_expense`, `column_amount`, etc. are showing as keys because **they haven't been added to your `Localizable.strings` or String Catalog yet**.

---

## 📋 Complete Key List (All 80 Keys)

### Import Data View (22 keys)
- `import_expenses_title`
- `import_expenses_subtitle`
- `select_csv_file`
- `select_csv_subtitle`
- `how_to_export_notion`
- `export_step_1`
- `export_step_2`
- `export_step_3`
- `export_step_4`
- `file_selected`
- `change`
- `preview`
- `total_rows_format`
- `detected_columns`
- `sample_data_first_three`
- `row_number_format`
- `import_expenses_cta`
- `importing`
- `import_status`
- `confirm_import`
- `import_all_expenses_format`
- `confirm_import_message`
- `cannot_access_file`
- `cannot_read_file_debug`
- `import_success_count`
- `import_partial_with_errors`
- `import_failed_error`

### CSV Format Info View (25 keys)
- `csv_format_guide`
- `csv_format_subtitle`
- `notion_format`
- `notion_format_desc`
- `smartspend_format`
- `smartspend_format_desc`
- `custom_format`
- `custom_format_desc`
- `required_columns`
- `required`
- `any_of_these`
- `example_header`
- `tips_title`
- `tip_case_insensitive`
- `tip_date_formats`
- `tip_categories_auto`
- `tip_currency_symbols`
- **`column_expense`** ⚠️
- **`column_amount`** ⚠️
- **`column_category`** ⚠️
- **`column_date`** ⚠️
- **`column_title`** ⚠️
- **`column_or_title_name`** ⚠️
- **`column_title_name_description`** ⚠️
- **`column_amount_price_cost`** ⚠️
- **`column_category_type`** ⚠️

### Export Data View (21 keys)
- `export_data_title`
- `export_data_types`
- `export_format_section`
- `date_range_section`
- `preview_section`
- `export_summary`
- `data_types_label`
- `selected_count`
- `format_label`
- `date_range_label`
- `estimated_size_label`
- `use_date_range`
- `start_date`
- `end_date`
- `export_button`
- `export_status_title`
- `export_success`
- `export_failed`
- `export_data_expenses`
- `export_data_recurring`
- `export_data_budgets`
- `export_data_goals`
- `export_data_salaries`
- `export_data_all`

### Deleted Expenses View (8 keys)
- `deleted_expenses_title`
- `search_deleted_expenses`
- `no_deleted_expenses`
- `no_deleted_expenses_found`
- `try_adjusting_filters_deleted`
- `deleted_expenses_appear_here`
- `restore_button`
- `delete_button`

### Common (4 keys)
- `cancel`
- `ok`
- `done`

---

## 🎯 MOST CRITICAL - These 9 Column Keys are MISSING:

```
"column_expense"
"column_amount"
"column_category"
"column_date"
"column_title"
"column_or_title_name"
"column_title_name_description"
"column_amount_price_cost"
"column_category_type"
```

**These are the keys showing as untranslated in the CSV Format Guide popup!**

---

## 🔧 HOW TO FIX:

### For Russian (your current language):

Copy and paste these into your `ru.lproj/Localizable.strings`:

```swift
// Column names for CSV Format Guide
"column_expense" = "Расход";
"column_amount" = "Сумма";
"column_category" = "Категория";
"column_date" = "Дата";
"column_title" = "Название";
"column_or_title_name" = "или Название/Имя";
"column_title_name_description" = "Название/Имя/Описание";
"column_amount_price_cost" = "Сумма/Цена/Стоимость";
"column_category_type" = "Категория/Тип";
```

### Steps:

1. **Find your localization file:**
   - Open your Xcode project
   - Look for `Localizable.strings` in your Russian language folder (`ru.lproj`)
   - OR find your String Catalog (`.xcstrings` file)

2. **Add the 9 column keys above**

3. **Clean and Rebuild:**
   - Press `Cmd + Shift + K` (Clean Build Folder)
   - Press `Cmd + B` (Build)
   - Run the app

4. **Test:**
   - Go to Settings → Import Data
   - Tap the info button (ⓘ)
   - All column names should now show in Russian!

---

## 📁 Reference Files:

1. **SETTINGS_LOCALIZATION_KEYS.md** - Complete list with all 80 keys in English, Russian, and Spanish
2. **COLUMN_NAMES_QUICK_FIX.md** - Just the 9 column keys in 20 languages for quick copy-paste
3. **CATEGORY_TRANSLATIONS.md** - Category names (separate feature, already done)

---

## ✅ Verification Checklist:

After adding the keys, verify these areas show in your language:

- [ ] Import Data main screen title and subtitle
- [ ] "Select CSV File" button text
- [ ] "How to export from Notion" instructions (4 steps)
- [ ] Preview section with "Detected Columns"
- [ ] Import confirmation dialog
- [ ] **CSV Format Guide popup title**
- [ ] **All 3 format cards (Notion, SmartSpend, Custom)**
- [ ] **All column names in the format cards** ⚠️ CRITICAL
- [ ] **"Required Columns" label**
- [ ] **Tips section (all 4 tips)**
- [ ] Export Data screen
- [ ] Deleted Expenses screen

---

## 🎉 Result:

Once you add these 9 column keys to your Russian localization file, **EVERYTHING** in the Import/Export/Deleted Expenses sections will be fully translated!

The code is perfect - it's just waiting for the localization strings to be added! 🇷🇺
