import SwiftUI
import AVFoundation

@available(iOS 14.0, *)
public struct MHSKSheetView: View {
  @StateObject private var viewModel = MHSKSheetViewModel()
  
  public init() {}
  
  public var body: some View {
    ZStack {
      CameraPreview(session: viewModel.captureSession, previewLayerCallback: { layer in
        viewModel.previewLayer = layer
      })
      .edgesIgnoringSafeArea(.all)
      
      // Your existing code
      if let barcodeFrame = viewModel.barcodeFrame {
        GeometryReader { geometry in
          RoundedRectangle(cornerRadius: 10)
            .stroke(Color.green, lineWidth: 3)
            .frame(width: barcodeFrame.width, height: barcodeFrame.height)
            .position(x: barcodeFrame.midX, y: barcodeFrame.midY)
          
          Color.red.opacity(0.3)
            .frame(width: barcodeFrame.width, height: barcodeFrame.height)
            .position(x: barcodeFrame.midX, y: barcodeFrame.midY)
        }
        .edgesIgnoringSafeArea(.all)
      }

      
      VStack {
        Spacer()
        
        if viewModel.isScanning {
          Text(viewModel.detectedCode ?? "Scanning for barcode...")
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(10)
        } else if let scannedCode = viewModel.scannedCode {
          Text("Captured: \(scannedCode)")
            .foregroundColor(.white)
            .padding()
            .background(Color.green.opacity(0.7))
            .cornerRadius(10)
        }
        
        HStack {
          Button(action: viewModel.toggleTorch) {
            Image(systemName: viewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
              .foregroundColor(.white)
              .padding()
              .background(Color.blue)
              .clipShape(Circle())
          }
          
          Spacer()
          
          if viewModel.detectedCode != nil {
            Button(action: viewModel.captureCode) {
              Image(systemName: "camera.circle.fill")
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .clipShape(Circle())
            }
          }
          
          Spacer()
          
          Button(action: viewModel.restartScanning) {
            Image(systemName: "arrow.clockwise")
              .foregroundColor(.white)
              .padding()
              .background(Color.blue)
              .clipShape(Circle())
          }
        }
        .padding()
      }
    }
    .onAppear(perform: viewModel.startScanning)
    .onDisappear(perform: viewModel.stopScanning)
  }
}

struct CameraPreview: UIViewRepresentable {
  let session: AVCaptureSession
  var previewLayerCallback: (AVCaptureVideoPreviewLayer) -> Void
  
  func makeUIView(context: Context) -> UIView {
    let view = UIView(frame: UIScreen.main.bounds)
    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.frame = view.bounds
    previewLayer.videoGravity = .resizeAspectFill
    view.layer.addSublayer(previewLayer)
    
    // Pass the preview layer back to the view model
    previewLayerCallback(previewLayer)
    
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {}
}


class MHSKSheetViewModel: NSObject, ObservableObject {
  @Published var isScanning = false
  @Published var scannedCode: String?
  @Published var detectedCode: String?
  @Published var isTorchOn = false
  @Published var barcodeFrame: CGRect?
  
  let captureSession = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer?
  private let metadataOutput = AVCaptureMetadataOutput()
  private let supportedBarcodeTypes: [AVMetadataObject.ObjectType] = [.ean8, .ean13, .pdf417, .code128]
  private let feedbackGenerator = UINotificationFeedbackGenerator()
  private let padding: CGFloat = 20 // Padding around the barcode
  
  override init() {
    super.init()
    setupCaptureSession()
  }
  
  private func setupCaptureSession() {
    guard let captureDevice = AVCaptureDevice.default(for: .video) else {
      print("No camera available.")
      return
    }
    
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(input)
      captureSession.addOutput(metadataOutput)
      
      previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      previewLayer?.frame = UIScreen.main.bounds
      previewLayer?.videoGravity = .resizeAspectFill
      print("Preview layer setup with frame: \(previewLayer?.frame ?? .zero)")
      
      metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = supportedBarcodeTypes
    } catch {
      print("Failed to set up the camera: \(error)")
    }
  }

  
  func startScanning() {
    DispatchQueue.global(qos: .background).async {
      self.captureSession.startRunning()
      DispatchQueue.main.async {
        self.isScanning = true
        self.barcodeFrame = nil
        self.detectedCode = nil
        self.scannedCode = nil
      }
    }
  }
  
  func stopScanning() {
    captureSession.stopRunning()
    isScanning = false
  }
  
  func restartScanning() {
    scannedCode = nil
    detectedCode = nil
    barcodeFrame = nil
    startScanning()
  }
  
  func captureCode() {
    scannedCode = detectedCode
    stopScanning()
  }
  
  func toggleTorch() {
    guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
    
    do {
      try device.lockForConfiguration()
      device.torchMode = device.torchMode == .on ? .off : .on
      isTorchOn = device.torchMode == .on
      device.unlockForConfiguration()
    } catch {
      print("Error toggling torch: \(error)")
    }
  }
}

extension MHSKSheetViewModel: AVCaptureMetadataOutputObjectsDelegate {
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    print("Metadata output called with objects: \(metadataObjects.count)")
    if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
      print("Barcode detected: \(metadataObject.stringValue ?? "Unknown")")
      if let previewLayer = self.previewLayer,
         let transformedObject = previewLayer.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject {
        print("Transformed barcode frame: \(transformedObject.bounds)")
        self.barcodeFrame = transformedObject.bounds.insetBy(dx: -self.padding, dy: -self.padding)
      } else {
        print("Failed to transform metadata object")
      }
      self.detectedCode = metadataObject.stringValue
    } else {
      print("No readable barcode detected")
      DispatchQueue.main.async {
        self.barcodeFrame = nil
        self.detectedCode = nil
      }
    }
  }

}
