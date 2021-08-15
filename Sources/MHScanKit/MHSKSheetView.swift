import SwiftUI
import AVFoundation

/// A view that provides a sheet interface for barcode scanning using the device's camera.
///
/// This view displays a camera preview, shows detected barcodes, and allows users to interact
/// with the scanning process through various controls. The appearance can be customized
/// using the `MHSKScannerConfiguration`.
@available(iOS 14.0, *)
public struct MHSKSheetView: View {
  /// The view model that manages the scanning logic and state.
  @StateObject private var viewModel = MHSKSheetViewModel()
  
  /// The delegate that receives error notifications from the scanning process.
  public var errorDelegate: MHSKErrorDelegate?
  
  /// The configuration options for customizing the scanner's appearance.
  private let configuration: MHSKScannerConfiguration
  
  /// Initializes a new instance of the barcode scanning view.
  ///
  /// - Parameters:
  ///   - configuration: A `MHSKScannerConfiguration` object to customize the scanner's appearance.
  ///     If not provided, default values will be used.
  ///   - errorDelegate: An optional delegate to receive error notifications.
  ///     If not provided, errors will not be reported outside this view.
  public init(
    configuration: MHSKScannerConfiguration = MHSKScannerConfiguration(),
    errorDelegate: MHSKErrorDelegate? = nil
  ) {
    self.configuration = configuration
    self.errorDelegate = errorDelegate
  }
  
  public var body: some View {
    ZStack {
      MHSKCameraPreview(session: viewModel.captureSession) { layer in
        viewModel.previewLayer = layer
      }
      .edgesIgnoringSafeArea(.all)
      
      MHSKBarcodeOverlay(
        barcodeFrame: viewModel.barcodeFrame,
        strokeColor: configuration.highlightColor,
        backgroundColor: configuration.highlightColor.opacity(0.3)
      )
      
      VStack {
        Spacer()
        
        if #available(iOS 17.0, *) {
          MHSKScanStatusView(
            isScanning: viewModel.isScanning,
            detectedCode: viewModel.detectedCode,
            scannedCode: viewModel.scannedCode,
            scanningBackgroundColor: configuration.statusBackgroundColor,
            capturedBackgroundColor: configuration.capturedBackgroundColor,
            textColor: configuration.statusTextColor
          )
          .padding(24)
        } else {
          // Fallback on earlier versions
        }
        
        MHSKControlButtonsView(
          viewModel: viewModel,
          primaryButtonColor: configuration.buttonColor,
          captureButtonColor: configuration.captureButtonColor,
          buttonSize: configuration.buttonSize
        )
      }
      .padding()
    }
    .onAppear {
      viewModel.errorDelegate = errorDelegate
      viewModel.startScanning()
    }
    .onDisappear(perform: viewModel.stopScanning)
  }
}
