import SwiftUI

struct DataExportView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var exporter = DataExporter.shared
    
    @State private var selectedDataTypes: Set<DataExporter.ExportData> = [.expenses]
    @State private var selectedFormat: DataExporter.ExportFormat = .csv
    @State private var useDateRange = false
    @State private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var isExporting = false
    @State private var exportedFileURL: URL?
    @State private var showingShareSheet = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Data to Export") {
                    ForEach(DataExporter.ExportData.allCases, id: \.self) { dataType in
                        HStack {
                            Image(systemName: dataType.icon)
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            Text(dataType.rawValue)
                            
                            Spacer()
                            
                            if selectedDataTypes.contains(dataType) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleDataType(dataType)
                        }
                    }
                }
                
                Section("Export Format") {
                    ForEach(DataExporter.ExportFormat.allCases, id: \.self) { format in
                        HStack {
                            Image(systemName: format.icon)
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            
                            Text(format.rawValue)
                            
                            Spacer()
                            
                            if selectedFormat == format {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFormat = format
                        }
                    }
                }
                
                Section("Date Range") {
                    Toggle("Use Date Range", isOn: $useDateRange)
                    
                    if useDateRange {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    }
                }
                
                Section("Preview") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Export Summary")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        HStack {
                            Text("Data Types:")
                            Spacer()
                            Text("\(selectedDataTypes.count) selected")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Format:")
                            Spacer()
                            Text(selectedFormat.rawValue)
                                .foregroundColor(.secondary)
                        }
                        
                        if useDateRange {
                            HStack {
                                Text("Date Range:")
                                Spacer()
                                Text("\(DateFormatter.shortStyle.string(from: startDate)) - \(DateFormatter.shortStyle.string(from: endDate))")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("Estimated Size:")
                            Spacer()
                            Text(estimatedFileSize)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: exportData) {
                        if isExporting {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text("Export")
                        }
                    }
                    .disabled(selectedDataTypes.isEmpty || isExporting)
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedFileURL {
                    ShareSheet(items: [url])
                }
            }
            .alert("Export Status", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func toggleDataType(_ dataType: DataExporter.ExportData) {
        if dataType == .all {
            if selectedDataTypes.contains(.all) {
                selectedDataTypes.removeAll()
            } else {
                selectedDataTypes = Set(DataExporter.ExportData.allCases)
            }
        } else {
            if selectedDataTypes.contains(dataType) {
                selectedDataTypes.remove(dataType)
                selectedDataTypes.remove(.all)
            } else {
                selectedDataTypes.insert(dataType)
                
                // Check if all individual types are selected
                let individualTypes = Set(DataExporter.ExportData.allCases.filter { $0 != .all })
                if selectedDataTypes.isSuperset(of: individualTypes) {
                    selectedDataTypes.insert(.all)
                }
            }
        }
    }
    
    private var estimatedFileSize: String {
        let dataManager = DataManager.shared
        var itemCount = 0
        
        if selectedDataTypes.contains(.expenses) || selectedDataTypes.contains(.all) {
            itemCount += dataManager.expenses.count
        }
        if selectedDataTypes.contains(.recurringExpenses) || selectedDataTypes.contains(.all) {
            itemCount += dataManager.recurringExpenses.count
        }
        if selectedDataTypes.contains(.budgets) || selectedDataTypes.contains(.all) {
            itemCount += dataManager.categoryBudgets.count
        }
        if selectedDataTypes.contains(.spendingGoals) || selectedDataTypes.contains(.all) {
            itemCount += dataManager.spendingGoals.count
        }
        if selectedDataTypes.contains(.monthlySalaries) || selectedDataTypes.contains(.all) {
            itemCount += dataManager.monthlySalaries.count
        }
        
        let estimatedKB = max(1, itemCount / 10)
        
        if estimatedKB < 1024 {
            return "\(estimatedKB) KB"
        } else {
            let estimatedMB = Double(estimatedKB) / 1024.0
            return String(format: "%.1f MB", estimatedMB)
        }
    }
    
    private func exportData() {
        isExporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let dateRange = useDateRange ? DateInterval(start: startDate, end: endDate) : nil
            let fileURL = exporter.exportData(
                dataTypes: selectedDataTypes,
                format: selectedFormat,
                dateRange: dateRange
            )
            
            DispatchQueue.main.async {
                isExporting = false
                
                if let url = fileURL {
                    exportedFileURL = url
                    showingShareSheet = true
                    alertMessage = "Export completed successfully!"
                } else {
                    alertMessage = "Export failed. Please try again."
                }
                
                showingAlert = true
            }
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let shortStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        return formatter
    }()
}

#Preview {
    DataExportView()
}
