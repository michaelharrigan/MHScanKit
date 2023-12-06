//
//  MHSKSheetViewController.swift
//
//
//  Created by Michael Harrigan on 10/28/22.
//
import AVFoundation
import UIKit

public class MHSKSheetViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
  
  let captureSession = AVCaptureSession()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    self.createCaptureSession()
    self.createCapture()
    
    let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    previewLayer.frame = view.layer.bounds
    self.view.layer.addSublayer(previewLayer)
  }

  func createCaptureSession() {
    guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
    
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      self.captureSession.addInput(input)
    } catch {
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.error)
      return
    }

    let metadataOutput = AVCaptureMetadataOutput()
    self.captureSession.addOutput(metadataOutput)
    metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .code128]
  }
  
  public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    if let firstObject = metadataObjects.first,
       let barcodeData = (firstObject as? AVMetadataMachineReadableCodeObject)?.stringValue {
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.success)
      self.captureSession.stopRunning()
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
  
  private func createCapture() {
    DispatchQueue.global(qos: .background).async {
      self.captureSession.startRunning()
    }
  }

}

