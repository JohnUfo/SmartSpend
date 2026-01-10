import SwiftUI

struct CategoryManagementView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var editingCategory: UserCategory?
    @State private var editingName = ""
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: ProblemExpensesView()) {
                    HStack {
                        Label("problem_expenses".localized, systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        
                        Spacer()
                        
                        let problemCount = dataManager.expenses.filter { $0.category == .other && $0.userCategoryId == nil }.count
                        if problemCount > 0 {
                            Text("\(problemCount)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.red, in: Capsule())
                        }
                    }
                }
            }
            
            Section("user_categories".localized) {
                if dataManager.userCategories.isEmpty {
                    Text("No categories yet. Tap + to add one.")
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    ForEach(dataManager.userCategories) { category in
                        HStack {
                            Label {
                                Text(category.name)
                                    .foregroundStyle(.primary)
                            } icon: {
                                Image(systemName: category.iconSystemName)
                                    .foregroundStyle(category.color)
                            }
                            
                            Spacer()
                            
                            Button {
                                editingCategory = category
                                editingName = category.name
                            } label: {
                                Image(systemName: "pencil")
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onDelete { indexSet in
                        deleteCategories(at: indexSet)
                    }
                }
                
                Button(action: {
                    showingAddCategory = true
                }) {
                    Label("add_category".localized, systemImage: "plus")
                }
            }
        }
        .navigationTitle("categories".localized)
        .alert("new_category".localized, isPresented: $showingAddCategory) {
            TextField("name".localized, text: $newCategoryName)
            Button("cancel".localized, role: .cancel) {
                newCategoryName = ""
            }
            Button("add".localized) {
                addCategory()
            }
        }
        .alert("edit_category".localized, isPresented: Binding(
            get: { editingCategory != nil },
            set: { if !$0 { editingCategory = nil } }
        )) {
            TextField("name".localized, text: $editingName)
            Button("cancel".localized, role: .cancel) {
                editingCategory = nil
                editingName = ""
            }
            Button("save".localized) {
                updateCategory()
            }
        }
    }
    
    private func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        
        let category = UserCategory(name: newCategoryName)
        dataManager.addUserCategory(category)
        newCategoryName = ""
    }
    
    private func updateCategory() {
        guard let category = editingCategory, !editingName.isEmpty else { return }
        
        var updated = category
        updated.name = editingName
        dataManager.updateUserCategory(updated)
        
        editingCategory = nil
        editingName = ""
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        offsets.forEach { index in
            let category = dataManager.userCategories[index]
            dataManager.deleteUserCategory(category)
        }
    }
}

#Preview {
    NavigationStack {
        CategoryManagementView()
    }
}

