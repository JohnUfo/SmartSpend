# 🚨 IMPORTANT - Localization Setup Instructions

I cannot directly modify your `Localizable.strings` file because I don't have access to it in the file system. Your localization files are likely in language-specific folders (.lproj) that aren't visible to me.

## 📁 WHERE TO FIND YOUR LOCALIZATION FILES:

Your localization files are typically located in:
- `en.lproj/Localizable.strings` (English)
- `es.lproj/Localizable.strings` (Spanish)
- `ru.lproj/Localizable.strings` (Russian)
- etc. for each language

OR you might be using:
- `Localizable.xcstrings` (String Catalog - newer method)

## 🔧 HOW TO ADD KEYS YOURSELF:

### Method 1: Using Xcode's Project Navigator

1. **Open your project in Xcode**
2. In the **Project Navigator** (left sidebar), look for:
   - A folder structure like `Resources` or `Supporting Files`
   - Files named `Localizable.strings`
   - OR a file named `Localizable.xcstrings` (String Catalog)

3. **If you see `Localizable.strings`:**
   - Click on it
   - You'll see a list of languages (en, es, ru, etc.)
   - Click on the Spanish (es) file
   - Scroll to the bottom
   - **Copy and paste these 9 keys:**

```swift
// CSV Format Guide - Column Names
"column_expense" = "Gasto";
"column_amount" = "Monto";
"column_category" = "Categoría";
"column_date" = "Fecha";
"column_title" = "Título";
"column_or_title_name" = "o Título/Nombre";
"column_title_name_description" = "Título/Nombre/Descripción";
"column_amount_price_cost" = "Monto/Precio/Costo";
"column_category_type" = "Categoría/Tipo";
```

4. **If you see `Localizable.xcstrings` (String Catalog):**
   - Double-click to open it
   - Click the **+** button to add new keys
   - For each of the 9 keys above:
     - Add the key name (e.g., `column_expense`)
     - Add the Spanish translation (e.g., `Gasto`)
     - Repeat for all 9 keys

5. **Save the file** (Cmd+S)

6. **Clean Build Folder** (Cmd+Shift+K)

7. **Build and Run** (Cmd+R)

---

### Method 2: Creating the File if it Doesn't Exist

If you don't have a `Localizable.strings` file:

1. **In Xcode, go to:** File → New → File
2. **Choose:** Strings File
3. **Name it:** `Localizable.strings`
4. **Click Create**
5. **Select the file in Project Navigator**
6. **In the File Inspector** (right sidebar):
   - Click "Localize..."
   - Choose your languages (Spanish, Russian, etc.)
7. **Open the Spanish version** and paste the 9 keys above

---

## 📋 ALL KEYS YOU NEED TO ADD (FOR ALL FEATURES):

For Spanish (es), here are ALL 80 keys:

### Import Data View (27 keys)
```swift
"import_expenses_title" = "Importar gastos";
"import_expenses_subtitle" = "Importa tus gastos desde Notion, archivos CSV u otras fuentes";
"select_csv_file" = "Seleccionar archivo CSV";
"select_csv_subtitle" = "Elige un archivo CSV de Notion u otras fuentes";
"how_to_export_notion" = "Cómo exportar desde Notion:";
"export_step_1" = "1. Abre tu base de datos de Notion";
"export_step_2" = "2. Haz clic en el menú ••• → Exportar";
"export_step_3" = "3. Selecciona formato CSV";
"export_step_4" = "4. Descarga y selecciona el archivo aquí";
"file_selected" = "Archivo seleccionado";
"change" = "Cambiar";
"preview" = "Vista previa";
"total_rows_format" = "%d filas totales";
"detected_columns" = "Columnas detectadas";
"sample_data_first_three" = "Datos de muestra (primeras 3 filas)";
"row_number_format" = "Fila %d";
"import_expenses_cta" = "Importar gastos";
"importing" = "Importando...";
"import_status" = "Estado de importación";
"confirm_import" = "Confirmar importación";
"import_all_expenses_format" = "Importar %d gastos";
"confirm_import_message" = "Esto agregará todos los gastos del archivo CSV a tus datos.";
"cannot_access_file" = "No se puede acceder al archivo seleccionado";
"cannot_read_file_debug" = "No se puede leer el archivo. Verifica el formato.";
"import_success_count" = "Se importaron %d gastos con éxito";
"import_partial_with_errors" = "Se importaron %d gastos, se omitieron %d con errores";
"import_failed_error" = "La importación falló: %@";
```

### CSV Format Info View (25 keys)
```swift
"csv_format_guide" = "Guía de formato CSV";
"csv_format_subtitle" = "Formatos compatibles para importar";
"notion_format" = "Formato Notion";
"notion_format_desc" = "Exportación directa de bases de datos Notion";
"smartspend_format" = "Formato SmartSpend";
"smartspend_format_desc" = "Formato de exportación estándar de SmartSpend";
"custom_format" = "Formato personalizado";
"custom_format_desc" = "Mapeo flexible de columnas";
"required_columns" = "Columnas requeridas";
"required" = "requerido";
"any_of_these" = "cualquiera de estos";
"example_header" = "Encabezado de ejemplo";
"tips_title" = "Consejos";
"tip_case_insensitive" = "Los nombres de columnas no distinguen mayúsculas";
"tip_date_formats" = "Los formatos de fecha se detectan automáticamente";
"tip_categories_auto" = "Las categorías del CSV se crearán automáticamente";
"tip_currency_symbols" = "El monto puede incluir símbolos de moneda";
"column_expense" = "Gasto";
"column_amount" = "Monto";
"column_category" = "Categoría";
"column_date" = "Fecha";
"column_title" = "Título";
"column_or_title_name" = "o Título/Nombre";
"column_title_name_description" = "Título/Nombre/Descripción";
"column_amount_price_cost" = "Monto/Precio/Costo";
"column_category_type" = "Categoría/Tipo";
```

### Export Data View (21 keys)
```swift
"export_data_title" = "Exportar datos";
"export_data_types" = "Datos a exportar";
"export_format_section" = "Formato de exportación";
"date_range_section" = "Rango de fechas";
"preview_section" = "Vista previa";
"export_summary" = "Resumen de exportación";
"data_types_label" = "Tipos de datos:";
"selected_count" = "%d seleccionados";
"format_label" = "Formato:";
"date_range_label" = "Rango de fechas:";
"estimated_size_label" = "Tamaño estimado:";
"use_date_range" = "Usar rango de fechas";
"start_date" = "Fecha de inicio";
"end_date" = "Fecha de fin";
"export_button" = "Exportar";
"export_status_title" = "Estado de exportación";
"export_success" = "¡Exportación completada con éxito!";
"export_failed" = "La exportación falló. Inténtalo de nuevo.";
"export_data_expenses" = "Gastos";
"export_data_recurring" = "Gastos recurrentes";
"export_data_budgets" = "Presupuestos";
"export_data_goals" = "Metas de gasto";
"export_data_salaries" = "Salarios mensuales";
"export_data_all" = "Todos los datos";
```

### Deleted Expenses View (8 keys)
```swift
"deleted_expenses_title" = "Gastos eliminados";
"search_deleted_expenses" = "Buscar gastos eliminados...";
"no_deleted_expenses" = "Sin gastos eliminados";
"no_deleted_expenses_found" = "No se encontraron gastos eliminados";
"try_adjusting_filters_deleted" = "Intenta ajustar tu búsqueda o filtros";
"deleted_expenses_appear_here" = "Los gastos eliminados aparecerán aquí";
"restore_button" = "Restaurar";
"delete_button" = "Eliminar";
```

---

## ⚠️ WHY I CAN'T ADD THEM DIRECTLY:

I'm an AI assistant that can only modify files that are visible in the project structure. Localization files are typically in special folders (.lproj directories) that aren't accessible to me through the file system interface I have.

**YOU must add these keys to your localization files manually** by following the instructions above.

---

## ✅ VERIFICATION:

After adding the keys:
1. Clean Build (Cmd+Shift+K)
2. Run the app
3. Go to Settings → Import Data
4. Tap the info button (ⓘ)
5. All text should now be in Spanish!

If you still see keys like `column_expense`, it means the keys weren't added to the localization file correctly.
