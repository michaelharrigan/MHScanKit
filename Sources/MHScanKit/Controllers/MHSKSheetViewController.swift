//
//  MHSKSheetViewController.swift
//
//
//  Created by Michael Harrigan on 10/28/22.
//
import AVFoundation
import UIKit

/// A view controller that manages the barcode scanning interface using the device's camera.
///
/// This view controller uses `AVCaptureSession` to capture video from the camera, detect barcodes,
/// and provide visual feedback to the user when a barcode is detected.
public class MHSKSheetViewController: UIViewController {
  
  /// A closure that is called when a barcode is successfully scanned.
  ///
  /// The closure receives an optional `String` containing the scanned barcode data.
  var onBarcodeScanned: ((String?) -> Void)?
  
  /// The capture session used for managing camera input and output.
  fileprivate let captureSession = AVCaptureSession()
  
  /// The video preview layer used for displaying the camera feed.
  fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
  
  /// The types of barcodes that this scanner can detect.
  fileprivate let supportedBarcodeTypes: [AVMetadataObject.ObjectType] = [.ean8, .ean13, .pdf417, .code128]
  
  /// The duration of animations used in the UI.
  fileprivate let animationDuration: TimeInterval = 0.2
  
  /// A feedback generator used to provide haptic feedback when a barcode is scanned.
  fileprivate let feedbackGenerator = UINotificationFeedbackGenerator()
  
  /// The padding applied to the barcode highlight view.
  fileprivate let padding: CGFloat = 20
  
  /// A view used to highlight the detected barcode.
  fileprivate lazy var codeHighlightView = MHSKCodeHighlightView()
  
  /// A view used to dim the area outside the detected barcode.
  fileprivate lazy var dimView = MHSKDimView()
  
  /// A closure that is called when an error occurs during the scanning process.
  ///
  /// - Parameter MHSKError: The error that occurred during scanning.
  var errorHandler: ((MHSKError) -> Void)?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    do {
      try setupCaptureSession()
      setupUI()
      startCapture()
      setupTapGesture()
    } catch let error as MHSKError {
      handleError(error)
    } catch {
      handleError(.setupFailed(error))
    }
  }
  
  /// Configures the camera capture session, setting up the input and output for barcode detection.
  ///
  /// - Throws: `MHSKError.cameraUnavailable` if the camera is not available.
  ///           `MHSKError.setupFailed` if there's an error during setup.
  private func setupCaptureSession() throws {
    guard let captureDevice = AVCaptureDevice.default(for: .video) else {
      throw MHSKError.cameraUnavailable
    }
    
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(input)
      
      let metadataOutput = AVCaptureMetadataOutput()
      captureSession.addOutput(metadataOutput)
      metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = supportedBarcodeTypes
    } catch {
      throw MHSKError.setupFailed(error)
    }
  }
  
  /// Sets up the user interface elements, including the camera preview and overlay views.
  ///
  /// This method adds the `previewLayer`, `dimView`, and `codeHighlightView` to the view hierarchy.
  private func setupUI() {
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer?.frame = view.bounds
    previewLayer?.videoGravity = .resizeAspectFill
    if let previewLayer = previewLayer {
      view.layer.addSublayer(previewLayer)
    }
    
    view.addSubview(dimView)
    view.addSubview(codeHighlightView)
    
    NSLayoutConstraint.activate([
      dimView.topAnchor.constraint(equalTo: view.topAnchor),
      dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  /// Sets up a tap gesture recognizer to handle focus adjustments based on user input.
  ///
  /// The gesture recognizer detects taps on the view and adjusts the camera's focus and exposure
  /// to the tapped point.
  private func setupTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    view.addGestureRecognizer(tapGesture)
  }
  
  /// Handles the tap gesture to adjust the camera's focus and exposure.
  ///
  /// - Parameter gesture: The tap gesture recognizer that triggered this action.
  @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: view)
    focus(at: location)
  }
  
  /// Adjusts the camera's focus and exposure to a specific point on the screen.
  ///
  /// - Parameter point: The point in the view where the focus and exposure should be adjusted.
  private func focus(at point: CGPoint) {
    guard let device = AVCaptureDevice.default(for: .video) else { return }
    
    do {
      try device.lockForConfiguration()
      
      if device.isFocusPointOfInterestSupported {
        device.focusPointOfInterest = point
        device.focusMode = .autoFocus
      }
      
      if device.isExposurePointOfInterestSupported {
        device.exposurePointOfInterest = point
        device.exposureMode = .autoExpose
      }
      
      device.unlockForConfiguration()
    } catch {
      print("Error setting focus: \(error)")
    }
  }
  
  /// Handles errors that occur during the scanning process.
  ///
  /// - Parameter error: The error to handle.
  private func handleError(_ error: MHSKError) {
    errorHandler?(error)
  }
  
  /// Displays an error message and triggers a haptic feedback notification.
  ///
  /// - Parameter message: The error message to display.
  private func showError(message: String) {
    feedbackGenerator.notificationOccurred(.error)
    print(message)
    // You can implement a more user-friendly error handling here
  }
  
  /// Starts the capture session in a background thread.
  ///
  /// This method begins the process of capturing video and detecting barcodes.
  private func startCapture() {
    DispatchQueue.global(qos: .background).async {
      self.captureSession.startRunning()
    }
  }
  
  /// Stops the capture session, halting the video feed and barcode detection.
  public func stopCapture() {
    captureSession.stopRunning()
  }
  
  public func toggleTorch() {
    do {
      try internalToggleTorch()
    } catch let error as MHSKError {
      handleError(error)
    } catch {
      handleError(.torchError(error))
    }
  }
  
  private func internalToggleTorch() throws {
    guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
      throw MHSKError.torchUnavailable
    }
    
    do {
      try device.lockForConfiguration()
      device.torchMode = device.torchMode == .on ? .off : .on
      device.unlockForConfiguration()
    } catch {
      throw MHSKError.torchError(error)
    }
  } /// The delegate that receives error notifications.
    ///
    /// Set this property to an object that conforms to `MHSKErrorDelegate`
    /// to receive callbacks when an error occurs during the scanning process.
}

extension MHSKSheetViewController: AVCaptureMetadataOutputObjectsDelegate {
  /// Called when the capture session outputs metadata objects, such as detected barcodes.
  ///
  /// - Parameters:
  ///   - output: The metadata output object that provided the metadata objects.
  ///   - metadataObjects: An array of `AVMetadataObject` instances detected during the session.
  ///   - connection: The capture connection that provided the metadata objects.
  public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
       let barcodeData = metadataObject.stringValue {
      
      feedbackGenerator.notificationOccurred(.success)
      
      if let transformedObject = previewLayer?.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject {
        updateCodeHighlightView(frame: transformedObject.bounds)
      }
      onBarcodeScanned?(barcodeData)
      self.stopCapture()
    } else {
      hideCodeHighlightView()
    }
  }
  
  /// Updates the position and visibility of the `codeHighlightView` based on the detected barcode's frame.
  ///
  /// - Parameter frame: The frame of the detected barcode, transformed to the view's coordinate system.
  private func updateCodeHighlightView(frame: CGRect) {
    let paddedFrame = frame.insetBy(dx: -padding, dy: -padding)
    UIView.animate(withDuration: animationDuration) {
      self.codeHighlightView.frame = paddedFrame
      self.codeHighlightView.isHidden = false
      self.updateDimView(with: paddedFrame)
    }
  }
  
  /// Hides the `codeHighlightView` and fades out the `dimView`.
  private func hideCodeHighlightView() {
    UIView.animate(withDuration: animationDuration) {
      self.codeHighlightView.isHidden = true
      self.dimView.alpha = 0
    }
  }
  
  /// Updates the `dimView` to create a cut-out effect around the highlighted barcode.
  ///
  /// - Parameter frame: The frame of the barcode to be highlighted and cut out from the dimmed view.
  private func updateDimView(with frame: CGRect) {
    let path = UIBezierPath(roundedRect: frame, cornerRadius: 10)
    path.append(UIBezierPath(rect: view.bounds))
    
    let maskLayer = CAShapeLayer()
    maskLayer.fillRule = .evenOdd
    maskLayer.path = path.cgPath
    
    dimView.layer.mask = maskLayer
    dimView.alpha = 1
  }
}
