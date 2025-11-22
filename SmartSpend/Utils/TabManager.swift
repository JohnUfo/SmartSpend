import SwiftUI

class TabManager: ObservableObject {
    static let shared = TabManager()
    
    @Published var selectedTab: Int = 0
    
    private init() {}
    
    func switchToExpensesTab() {
        selectedTab = 1 // Expenses tab index
    }
}
