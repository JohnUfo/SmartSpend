import SwiftUI

struct CategoryManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    
    @State private var name: String = ""
    @State private var iconSystemName: String = "tag.fill"
    @State private var selectedColorName: String = "systemBlue"
    @State private var showValidationError: Bool = false
    @State private var editingCategory: UserCategory? = nil
    @State private var showingEditor: Bool = false
    
    private let availableIcons = [
        "tag.fill", "cart.fill", "bag.fill", "creditcard.fill", "banknote.fill",
        "house.fill", "car.fill", "bus.fill", "tram.fill", "airplane",
        "fork.knife", "cup.and.saucer.fill", "wineglass.fill", "birthday.cake.fill",
        "heart.fill", "cross.case.fill", "pills.fill", "stethoscope",
        "book.fill", "graduationcap.fill", "pencil", "backpack.fill",
        "gamecontroller.fill", "tv.fill", "headphones", "music.note",
        "sportscourt.fill", "figure.run", "dumbbell.fill", "bicycle",
        "gift.fill", "sparkles", "star.fill", "bolt.fill",
        "wrench.fill", "hammer.fill", "paintbrush.fill", "scissors",
        "phone.fill", "envelope.fill", "wifi", "network",
        "pawprint.fill", "leaf.fill", "drop.fill", "flame.fill",
        "building.2.fill", "storefront.fill", "theatermasks.fill", "ticket.fill"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Create New Category Button
                    Button(action: {
                        editingCategory = nil
                        resetForm()
                        showingEditor = true
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.accentColor, in: Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Create New Category")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("Add a custom category for your expenses")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(16)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                    
                    // Your Custom Categories
                    if !dataManager.userCategories.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Categories")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 4)
                            
                            ForEach(dataManager.userCategories) { category in
                                customCategoryRow(category)
                            }
                        }
                    }
                    
                    // Default Categories
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Default Categories")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 4)
                        
                        ForEach([ExpenseCategory.other], id: \.self) { category in
                            defaultCategoryRow(category)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.medium)
                }
            }
            .sheet(isPresented: $showingEditor) {
                categoryEditorSheet
            }
            .alert("Invalid Name", isPresented: $showValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a unique category name.")
            }
        }
    }
    
    // MARK: - Custom Category Row
    
    private func customCategoryRow(_ category: UserCategory) -> some View {
        HStack(spacing: 12) {
            Image(systemName: category.iconSystemName)
                .font(.title2)
                .foregroundStyle(category.color)
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("Created \(category.createdAt.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Menu {
                Button(action: {
                    editingCategory = category
                    name = category.name
                    iconSystemName = category.iconSystemName
                    selectedColorName = category.colorName
                    showingEditor = true
                }) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: {
                    dataManager.deleteUserCategory(category)
                }) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Default Category Row
    
    private func defaultCategoryRow(_ category: ExpenseCategory) -> some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.title2)
                .foregroundStyle(category.color)
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.localizedName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("System category")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "lock.fill")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Category Editor Sheet
    
    private var categoryEditorSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview
                    VStack(spacing: 12) {
                        Image(systemName: iconSystemName)
                            .font(.system(size: 50))
                            .foregroundStyle(color(for: selectedColorName))
                            .frame(width: 80, height: 80)
                        
                        Text(name.isEmpty ? "Category Name" : name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(name.isEmpty ? .secondary : .primary)
                    }
                    .padding(.top, 8)
                    
                    // Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        TextField("Enter category name", text: $name)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
                            .textInputAutocapitalization(.words)
                    }
                    .padding(.horizontal)
                    
                    // Icon Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Icon")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        iconGrid
                            .padding(.horizontal)
                    }
                    
                    // Color Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        colorGrid
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(editingCategory != nil ? "Edit Category" : "New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingEditor = false
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(editingCategory != nil ? "Save" : "Add") {
                        saveCategory()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private var colorGrid: some View {
        let columns = [GridItem(.adaptive(minimum: 40), spacing: 12)]
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(UserCategory.presetColors, id: \.self) { colorName in
                let isSelected = selectedColorName == colorName
                Circle()
                    .fill(color(for: colorName))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                            .padding(3)
                    )
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .opacity(isSelected ? 1 : 0)
                    )
                    .onTapGesture { selectedColorName = colorName }
            }
        }
    }
    
    private var iconGrid: some View {
        let columns = [GridItem(.adaptive(minimum: 48), spacing: 8)]
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(availableIcons, id: \.self) { iconName in
                let isSelected = iconSystemName == iconName
                Image(systemName: iconName)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? color(for: selectedColorName) : .primary)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? color(for: selectedColorName) : Color.clear, lineWidth: 2)
                    )
                    .onTapGesture { iconSystemName = iconName }
            }
        }
    }
    
    private func color(for name: String) -> Color {
        switch name {
        case "systemRed": return Color(.systemRed)
        case "systemOrange": return Color(.systemOrange)
        case "systemYellow": return Color(.systemYellow)
        case "systemGreen": return Color(.systemGreen)
        case "systemMint": return Color(.systemMint)
        case "systemTeal": return Color(.systemTeal)
        case "systemCyan": return Color(.systemCyan)
        case "systemBlue": return Color(.systemBlue)
        case "systemIndigo": return Color(.systemIndigo)
        case "systemPurple": return Color(.systemPurple)
        case "systemPink": return Color(.systemPink)
        case "systemBrown": return Color(.systemBrown)
        case "systemGray": return Color(.systemGray)
        default: return Color(.systemBlue)
        }
    }
    
    private func resetForm() {
        name = ""
        iconSystemName = "tag.fill"
        selectedColorName = "systemBlue"
    }
    
    private func saveCategory() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Check for duplicates (excluding current category if editing)
        let isDuplicate = dataManager.userCategories.contains { existingCategory in
            existingCategory.name.lowercased() == trimmed.lowercased() &&
            existingCategory.id != editingCategory?.id
        }
        
        if isDuplicate {
            showValidationError = true
            return
        }
        
        if let existingCategory = editingCategory {
            // Update existing category by removing old and adding updated
            dataManager.deleteUserCategory(existingCategory)
            let updatedCategory = UserCategory(
                name: trimmed,
                iconSystemName: iconSystemName,
                colorName: selectedColorName
            )
            // Preserve the original creation date by creating a new one with same data
            dataManager.addUserCategory(updatedCategory)
        } else {
            // Create new category
            let newCategory = UserCategory(
                name: trimmed,
                iconSystemName: iconSystemName,
                colorName: selectedColorName
            )
            dataManager.addUserCategory(newCategory)
        }
        
        showingEditor = false
        resetForm()
    }
}

#Preview {
    CategoryManagementView()
}


