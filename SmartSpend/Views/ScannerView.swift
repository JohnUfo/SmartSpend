import SwiftUI

struct ScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCustomCamera = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isProcessing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var onScanCompleted: (OCRResult) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.blue, lineWidth: 2)
                        )
                        .padding()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.viewfinder")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue.gradient)
                        
                        Text("Scan Your Receipt")
                            .font(.title2.bold())
                        
                        Text("Position your receipt clearly in the frame. We'll automatically extract the merchant and amount.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                VStack(spacing: 16) {
                    if selectedImage == nil {
                        Button {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                showingCustomCamera = true
                            } else {
                                errorMessage = "Camera is not available on this device."
                                showingError = true
                            }
                        } label: {
                            Label("Take a Photo", systemImage: "camera.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button {
                            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                                sourceType = .photoLibrary
                                showingImagePicker = true
                            } else {
                                errorMessage = "Photo library is not available."
                                showingError = true
                            }
                        } label: {
                            Label("Choose from Library", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    } else {
                        Button(action: processReceipt) {
                            if isProcessing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Label("Process Receipt", systemImage: "sparkles")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(isProcessing)
                        
                        Button("Retake") {
                            selectedImage = nil
                        }
                        .foregroundStyle(.red)
                        .disabled(isProcessing)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .navigationTitle("Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingCustomCamera) {
                SmartCameraView(capturedImage: $selectedImage)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: sourceType)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func processReceipt() {
        guard let image = selectedImage else { return }
        isProcessing = true
        
        ReceiptOCRService.shared.recognizeText(from: image) { result in
            DispatchQueue.main.async {
                isProcessing = false
                onScanCompleted(result)
                dismiss()
            }
        }
    }
}

#Preview {
    ScannerView { _ in }
}
