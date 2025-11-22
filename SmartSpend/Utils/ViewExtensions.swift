import SwiftUI

extension View {
    /// Applies a conditional modifier to the view
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

class DeleteButtonManager: ObservableObject {
    static let shared = DeleteButtonManager()
    
    @Published var activeExpenseId: UUID?
    
    private init() {}
    
    func setActiveExpense(_ id: UUID?) {
        activeExpenseId = id
    }
}