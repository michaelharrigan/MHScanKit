//
//  MHSKSheetViewModel.swift
//
//
//  Created by Michael Harrigan on 8/21/24.
//

import SwiftUI
import AVFoundation

/// A view model that handles the barcode scanning logic and manages the camera session.
class MHSKSheetViewModel: NSObject, ObservableObject {
  /// Indicates whether the scanner is currently active.
  @Published var isScanning = false
  /// The code that has been successfully captured.
  @Published var scannedCode: String?
  /// The code that is currently detected during scanning.
  @Published var detectedCode: String?
  /// Indicates whether the torch (flashlight) is currently on.
  @Published var isTorchOn = false
  /// The frame of the detected barcode in the camera preview.
  @Published var barcodeFrame: CGRect?

  /// The video preview layer used for displaying the camera feed.
  var previewLayer: AVCaptureVideoPreviewLayer?
  
  /// The capture session used for managing the camera input and output.
  let captureSession = AVCaptureSession()
  
  /// The metadata output for capturing barcode information from the video feed.
  private let metadataOutput = AVCaptureMetadataOutput()
  
  /// The types of barcodes that this scanner can detect.
  private let supportedBarcodeTypes: [AVMetadataObject.ObjectType] = [.ean8, .ean13, .pdf417, .code128]
  
  /// A feedback generator used to provide haptic feedback when a barcode is scanned.
  private let feedbackGenerator = UINotificationFeedbackGenerator()
  
  /// The padding applied to the barcode highlight view.
  private let padding: CGFloat = 20
  
  /// The delegate that receives error notifications.
  weak var errorDelegate: MHSKErrorDelegate?

  override init() {
    super.init()
    setupCaptureSession()
  }
  
  private func handleError(_ error: MHSKError) {
    DispatchQueue.main.async {
      self.errorDelegate?.scanKit(didEncounterError: error)
    }
  }
  
  /// Sets up the camera capture session, configuring the input and metadata output.
  private func setupCaptureSession() {
    guard let captureDevice = AVCaptureDevice.default(for: .video) else {
      handleError(.cameraUnavailable)
      return
    }
    
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(input)
      captureSession.addOutput(metadataOutput)
      
      metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = supportedBarcodeTypes
    } catch {
      handleError(.setupFailed(error))
    }
  }
  
  /// Starts the barcode scanning process.
  ///
  /// This method activates the capture session and resets the scanning state.
  func startScanning() {
    DispatchQueue.global(qos: .background).async {
      self.captureSession.startRunning()
      DispatchQueue.main.async {
        self.isScanning = true
        self.resetScanState()
      }
    }
  }
  
  /// Stops the barcode scanning process.
  ///
  /// This method deactivates the capture session.
  func stopScanning() {
    captureSession.stopRunning()
    isScanning = false
  }
  
  /// Restarts the barcode scanning process.
  ///
  /// This method resets the scanning state and reactivates the capture session.
  func restartScanning() {
    resetScanState()
    startScanning()
  }
  
  /// Captures the currently detected barcode.
  ///
  /// This method stores the detected code and stops the scanning process.
  func captureCode() {
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    impactMed.impactOccurred()
    scannedCode = detectedCode
    stopScanning()
  }
  
  /// Toggles the device's torch (flashlight) on or off.
  ///
  /// This method changes the torch mode on the device if the torch is available.
  func toggleTorch() {
    do {
      try MHSKDeviceCapabilitiesHelper.toggleTorch(on: !isTorchOn)
      isTorchOn.toggle()
    } catch {
      handleError(error as? MHSKError ?? .torchError(error))
    }
  }
  
  /// Resets the scanning state, clearing any detected or captured codes and barcode frame.
  private func resetScanState() {
    scannedCode = nil
    detectedCode = nil
    barcodeFrame = nil
  }
}

extension MHSKSheetViewModel: AVCaptureMetadataOutputObjectsDelegate {
  /// Handles the output of metadata objects from the capture session.
  ///
  /// This method processes the metadata objects detected during scanning and updates the barcode frame and detected code.
  ///
  /// - Parameters:
  ///   - output: The metadata output object that provided the metadata objects.
  ///   - metadataObjects: An array of metadata objects detected during scanning.
  ///   - connection: The capture connection that provided the metadata objects.
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
      resetScanState()
      return
    }
    
    if let previewLayer = previewLayer {
      updateBarcodeFrame(for: metadataObject, with: previewLayer)
    }
    
    detectedCode = metadataObject.stringValue
  }
  
  /// Updates the frame of the detected barcode in the camera preview.
  ///
  /// This method transforms the detected metadata object into a frame that can be used
  /// to display an overlay in the camera preview.
  ///
  /// - Parameters:
  ///   - metadataObject: The metadata object representing the detected barcode.
  ///   - previewLayer: The video preview layer used to display the camera feed.
  private func updateBarcodeFrame(for metadataObject: AVMetadataMachineReadableCodeObject, with previewLayer: AVCaptureVideoPreviewLayer) {
    if let transformedObject = previewLayer.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject {
      barcodeFrame = transformedObject.bounds.insetBy(dx: -padding, dy: -padding)
    } else {
      resetScanState()
    }
  }
}
