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
  private lazy var codeHighlightView: UIView = {
    let view = UIView()
    view.layer.borderColor = UIColor.green.cgColor
    view.layer.borderWidth = 2.0
    view.isHidden = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private var previewLayer: AVCaptureVideoPreviewLayer?
  
  private let supportedBarcodeTypes: [AVMetadataObject.ObjectType] = [.ean8, .ean13, .pdf417, .code128]
  
  // Constants for better code readability
  private let animationDuration: TimeInterval = 0.2
  private let feedbackGenerator = UINotificationFeedbackGenerator()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    setupCaptureSession()
    setupUI()
    createCapture()
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
    previewLayer?.frame = view.layer.bounds
    if let previewLayer = previewLayer {
      view.layer.addSublayer(previewLayer)
    }
    view.addSubview(codeHighlightView)
  }
  
  private func showError(message: String) {
    feedbackGenerator.notificationOccurred(.error)
    print(message) // You can handle the error more gracefully, e.g., by displaying an alert to the user.
  }
  
  private func createCapture() {
    DispatchQueue.global(qos: .background).async {
      self.captureSession.startRunning()
    }
  }
}

extension MHSKSheetViewController: AVCaptureMetadataOutputObjectsDelegate {
  public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    if let firstObject = metadataObjects.first,
       let barcodeData = (firstObject as? AVMetadataMachineReadableCodeObject)?.stringValue {
      
      if let transformedObject = previewLayer?.transformedMetadataObject(for: firstObject) as? AVMetadataMachineReadableCodeObject {
        let codeFrame = transformedObject.bounds
        DispatchQueue.main.async {
          self.updateCodeHighlightView(frame: codeFrame)
        }
      }
      
      feedbackGenerator.notificationOccurred(.success)
      captureSession.stopRunning()
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
        let alert = UIAlertController(title: barcodeData, message: "Copy barcode", preferredStyle: .alert)
        let copyAction = UIAlertAction(title: "Copy", style: .default) { _ in
          UIPasteboard.general.string = barcodeData
          self.createCapture()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
          self.createCapture()
        }
        alert.addAction(copyAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
      }
    }
  }
  
  private func updateCodeHighlightView(frame: CGRect) {
    UIView.animate(withDuration: animationDuration) {
      self.codeHighlightView.frame = frame
      self.codeHighlightView.isHidden = false
    }
  }
}
