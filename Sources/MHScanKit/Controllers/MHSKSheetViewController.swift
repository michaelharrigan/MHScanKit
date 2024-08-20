//
//  MHSKSheetViewController.swift
//
//
//  Created by Michael Harrigan on 10/28/22.
//
import AVFoundation
import UIKit

public class MHSKSheetViewController: UIViewController {
  private let captureSession = AVCaptureSession()
  private var previewLayer: AVCaptureVideoPreviewLayer?
  
  private lazy var codeHighlightView: UIView = {
    let view = UIView()
    view.layer.borderColor = UIColor.green.cgColor
    view.layer.borderWidth = 2.0
    view.layer.cornerRadius = 10
    view.clipsToBounds = true
    view.isHidden = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private lazy var dimView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private let supportedBarcodeTypes: [AVMetadataObject.ObjectType] = [.ean8, .ean13, .pdf417, .code128]
  private let animationDuration: TimeInterval = 0.2
  private let feedbackGenerator = UINotificationFeedbackGenerator()
  private let padding: CGFloat = 20 // Padding around the barcode
  
  public var onBarcodeScanned: ((String) -> Void)?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupCaptureSession()
    setupUI()
    startCapture()
    setupTapGesture()
  }
  
  private func setupCaptureSession() {
    guard let captureDevice = AVCaptureDevice.default(for: .video) else {
      showError(message: "No camera available.")
      return
    }
    
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(input)
      
      let metadataOutput = AVCaptureMetadataOutput()
      captureSession.addOutput(metadataOutput)
      metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      metadataOutput.metadataObjectTypes = supportedBarcodeTypes
    } catch {
      showError(message: "Failed to set up the camera.")
    }
  }
  
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
  
  private func setupTapGesture() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    view.addGestureRecognizer(tapGesture)
  }
  
  @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: view)
    focus(at: location)
  }
  
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
  
  private func showError(message: String) {
    feedbackGenerator.notificationOccurred(.error)
    print(message)
    // You can implement a more user-friendly error handling here
  }
  
  private func startCapture() {
    DispatchQueue.global(qos: .background).async {
      self.captureSession.startRunning()
    }
  }
  
  public func stopCapture() {
    captureSession.stopRunning()
  }
  
  public func toggleTorch() {
    guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
    
    do {
      try device.lockForConfiguration()
      device.torchMode = device.torchMode == .on ? .off : .on
      device.unlockForConfiguration()
    } catch {
      print("Error toggling torch: \(error)")
    }
  }
}

extension MHSKSheetViewController: AVCaptureMetadataOutputObjectsDelegate {
  public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
       let barcodeData = metadataObject.stringValue {
      
      feedbackGenerator.notificationOccurred(.success)
      
      if let transformedObject = previewLayer?.transformedMetadataObject(for: metadataObject) as? AVMetadataMachineReadableCodeObject {
        updateCodeHighlightView(frame: transformedObject.bounds)
      }
      
      onBarcodeScanned?(barcodeData)
    } else {
      hideCodeHighlightView()
    }
  }
  
  private func updateCodeHighlightView(frame: CGRect) {
    let paddedFrame = frame.insetBy(dx: -padding, dy: -padding)
    UIView.animate(withDuration: animationDuration) {
      self.codeHighlightView.frame = paddedFrame
      self.codeHighlightView.isHidden = false
      self.updateDimView(with: paddedFrame)
    }
  }
  
  private func hideCodeHighlightView() {
    UIView.animate(withDuration: animationDuration) {
      self.codeHighlightView.isHidden = true
      self.dimView.alpha = 0
    }
  }
  
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
