import SwiftUI

struct CurrencySelectionView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCurrency: Currency
    
    init() {
        self._selectedCurrency = State(initialValue: DataManager.shared.user.currency)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Select Currency") {
                    ForEach(Currency.allCases, id: \.self) { currency in
                        CurrencyRowView(
                            currency: currency,
                            isSelected: selectedCurrency == currency,
                            onTap: { selectedCurrency = currency }
                        )
                    }
                }
                
                Section {
                    Text("All monetary values in the app will be displayed in the selected currency format.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Currency")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    cancelButton
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    saveButton
                }
            }
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            dismiss()
        }
        .foregroundStyle(.tint)
    }
    
    private var saveButton: some View {
        Button("Save") {
            dataManager.updateCurrency(selectedCurrency)
            dismiss()
        }
        .fontWeight(.semibold)
        .foregroundStyle(.tint)
    }
}

struct CurrencyRowView: View {
    let currency: Currency
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(currency.rawValue)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(currency.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.tint)
                        .font(.title3)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CurrencySelectionView()
}
