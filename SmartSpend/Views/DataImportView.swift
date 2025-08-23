import SwiftUI
import UniformTypeIdentifiers

struct DataImportView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var importer = DataImporter.shared
    @ObservedObject private var dataManager = DataManager.shared
    
    @State private var showingFilePicker = false
    @State private var selectedFileURL: URL?
    @State private var previewData: (headers: [String], sampleRows: [[String]], totalRows: Int)?
    @State private var isImporting = false
    @State private var importResult: DataImporter.ImportResult?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue)
                    
                    Text("Import Expenses")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Import your expenses from Notion, CSV files, or other sources")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // File Selection
                if let selectedFileURL = selectedFileURL {
                    selectedFileView(fileURL: selectedFileURL)
                } else {
                    fileSelectionView
                }
                
                // Preview Section
                if let previewData = previewData {
                    previewSection(previewData: previewData)
                }
                
                Spacer()
                
                // Import Button
                if selectedFileURL != nil && previewData != nil {
                    importButton
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker(selectedURL: $selectedFileURL, onFileSelected: handleFileSelection)
            }
            .alert("Import Status", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .confirmationDialog(
                "Confirm Import",
                isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {
                Button("Import All \(previewData?.totalRows ?? 0) Expenses") {
                    performImport()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will add all expenses to your SmartSpend app. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - View Components
    
    private var fileSelectionView: some View {
        VStack(spacing: 16) {
            Button {
                showingFilePicker = true
            } label: {
                VStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                    
                    Text("Select CSV File")
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text("Choose a CSV file from Notion or other sources")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5]))
                )
            }
            .buttonStyle(.plain)
            
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Text("How to export from Notion:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("1. Open your expenses database in Notion")
                    Text("2. Click the ••• menu in the top right")
                    Text("3. Select 'Export' → 'CSV'")
                    Text("4. Download and select the file here")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
            
            // Debug button
            Button {
                debugCSVFile()
            } label: {
                HStack {
                    Image(systemName: "ladybug")
                    Text("Debug CSV File")
                }
                .font(.caption)
                .foregroundStyle(.orange)
            }
            .buttonStyle(.plain)
        }
    }
    
    private func selectedFileView(fileURL: URL) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundStyle(.green)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(fileURL.lastPathComponent)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("File selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button("Change") {
                    selectedFileURL = nil
                    previewData = nil
                }
                .font(.caption)
                .foregroundStyle(.blue)
            }
            .padding()
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func previewSection(previewData: (headers: [String], sampleRows: [[String]], totalRows: Int)) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "eye")
                    .foregroundStyle(.orange)
                
                Text("Preview")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(previewData.totalRows) total rows")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Headers
            VStack(alignment: .leading, spacing: 8) {
                Text("Detected Columns:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 4) {
                    ForEach(previewData.headers, id: \.self) { header in
                        Text(header)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
            
            // Sample Data
            VStack(alignment: .leading, spacing: 8) {
                Text("Sample Data (first 3 rows):")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ForEach(Array(previewData.sampleRows.prefix(3).enumerated()), id: \.offset) { index, row in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Row \(index + 1):")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        Text(row.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 4))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var importButton: some View {
        Button {
            showingConfirmation = true
        } label: {
            HStack {
                if isImporting {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: "square.and.arrow.down")
                }
                
                Text(isImporting ? "Importing..." : "Import Expenses")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isImporting ? Color.gray : Color.blue,
                in: RoundedRectangle(cornerRadius: 12)
            )
            .foregroundStyle(.white)
        }
        .disabled(isImporting)
    }
    
    // MARK: - File Selection Handler
    
    private func handleFileSelection(_ url: URL) {
        print("🔍 Selected file: \(url.lastPathComponent)")
        print("🔍 File path: \(url.path)")
        
        selectedFileURL = url
        
        // Start security-scoped resource access
        guard url.startAccessingSecurityScopedResource() else {
            print("❌ Failed to access security-scoped resource")
            alertMessage = "Could not access the selected file. Please try again."
            showingAlert = true
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }
        
        // Preview the file
        previewFile(url: url)
    }
    
    private func previewFile(url: URL) {
        if let preview = importer.previewCSVImport(fileURL: url) {
            previewData = preview
            print("✅ Preview successful: \(preview.totalRows) rows detected")
        } else {
            alertMessage = "Could not read the selected file. Please make sure it's a valid CSV file.\n\nDebug info: Check console logs for details."
            showingAlert = true
            print("❌ Preview failed - check console for details")
        }
    }
    
    // MARK: - Methods
    
    private func performImport() {
        guard let fileURL = selectedFileURL else { return }
        
        isImporting = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let result = importer.importFromCSV(fileURL: fileURL, dataManager: dataManager)
            
            DispatchQueue.main.async {
                isImporting = false
                importResult = result
                
                switch result {
                case .success(let importedCount, let skippedCount, let errors):
                    if errors.isEmpty {
                        alertMessage = "Successfully imported \(importedCount) expenses!"
                    } else {
                        alertMessage = "Imported \(importedCount) expenses, skipped \(skippedCount) with errors. Check the console for details."
                        print("Import errors: \(errors)")
                    }
                    
                case .failure(let error):
                    alertMessage = "Import failed: \(error)"
                }
                
                showingAlert = true
                
                // Dismiss after successful import
                if case .success(let importedCount, _, _) = result, importedCount > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func debugCSVFile() {
        guard let fileURL = selectedFileURL else {
            alertMessage = "No file selected for debugging."
            showingAlert = true
            return
        }
        
        do {
            let sampleContent = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = sampleContent.components(separatedBy: .newlines)
            
            print("🔍 Debugging file: \(fileURL.lastPathComponent)")
            print("🔍 File path: \(fileURL.path)")
            print("🔍 File size: \(try FileManager.default.attributesOfItem(atPath: fileURL.path)[.size] as? Int64 ?? 0) bytes")
            print("🔍 Total lines: \(lines.count)")
            
            if lines.count > 0 {
                print("🔍 First line: \(lines[0])")
            }
            if lines.count > 1 {
                print("🔍 Second line: \(lines[1])")
            }
            if lines.count > 2 {
                print("🔍 Third line: \(lines[2])")
            }
            
            alertMessage = "Debug info for \(fileURL.lastPathComponent):\n\nTotal Lines: \(lines.count)\n\nFirst 3 lines:\n\(lines.prefix(3).joined(separator: "\n"))"
            showingAlert = true
            
        } catch {
            alertMessage = "Failed to read file for debugging: \(error.localizedDescription)"
            showingAlert = true
            print("❌ Debug file failed: \(error)")
        }
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    let onFileSelected: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.commaSeparatedText, UTType.plainText])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("❌ Failed to access security-scoped resource")
                return
            }
            
            // Store the URL and call the callback
            parent.selectedURL = url
            parent.onFileSelected(url)
        }
    }
}

#Preview {
    DataImportView()
}
