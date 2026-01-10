import AVFoundation
import UIKit

class CameraService: NSObject, ObservableObject {
    @Published var photo: UIImage?
    @Published var session = AVCaptureSession()
    @Published var isCameraAuthorized = false
    
    private let output = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isCameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                DispatchQueue.main.async {
                    self.isCameraAuthorized = authorized
                    if authorized {
                        self.setup()
                    }
                }
            }
        default:
            self.isCameraAuthorized = false
        }
    }
    
    func setup() {
        checkPermission()
        guard isCameraAuthorized else { return }
        if !session.inputs.isEmpty { return } // Prevent multiple setups
        
        do {
            session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        } catch {
            print("❌ Camera Setup Error: \(error.localizedDescription)")
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func stop() {
        session.stopRunning()
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else { 
            print("❌ Capture Error: \(error!.localizedDescription)")
            return 
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        DispatchQueue.main.async {
            self.photo = UIImage(data: imageData)
        }
    }
}
