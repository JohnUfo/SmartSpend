import SwiftUI

struct SmartCameraView: View {
    @StateObject private var camera = CameraService()
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()
            
            // UI Overlay
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .padding()
                            .background(.black.opacity(0.3), in: Circle())
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Scanning Guide
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(.white.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [10]))
                    .frame(width: 300, height: 450)
                    .overlay(
                        VStack {
                            Spacer()
                            Text("Center your receipt here")
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(.black.opacity(0.4), in: Capsule())
                                .padding(.bottom, 20)
                        }
                    )
                
                Spacer()
                
                // Take Photo Controls
                HStack {
                    Spacer()
                    
                    Button {
                        camera.capturePhoto()
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                            Circle()
                                .fill(.white)
                                .frame(width: 65, height: 65)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            camera.setup()
        }
        .onChange(of: camera.photo) { _, newValue in
            if let newPhoto = newValue {
                capturedImage = newPhoto
                camera.stop()
                dismiss()
            }
        }
    }
}
