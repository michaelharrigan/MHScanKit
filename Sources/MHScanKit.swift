//
//  MHScanKit.swift
//
//
//  Created by Michael Harrigan on 8/21/24.
//

import SwiftUI
import AVFoundation

/// A protocol that defines methods for receiving barcode scanning results.
///
/// Implement this protocol to receive callbacks when `MHScanKit` successfully scans a barcode.
/// The delegate is responsible for handling the scanned barcode data.
public protocol MHScanKitDelegate: AnyObject {
  
  /// Called when a barcode has been successfully scanned.
  ///
  /// This method is invoked by the `MHScanKit` instance when it detects and successfully
  /// decodes a barcode. Use this method to process the scanned barcode value and update
  /// your app's UI or perform any necessary actions.
  ///
  /// - Parameters:
  ///   - scanKit: The `MHScanKit` instance that performed the scan.
  ///   - value: A string containing the decoded barcode value.
  ///
  /// - Note: This method is called on the main thread, so it's safe to update UI directly from this method.
  func scanKit(_ scanKit: MHScanKit, didScanBarcode value: String)
}

/// A class that provides barcode scanning functionality.
///
/// `MHScanKit` encapsulates the core functionality for barcode scanning,
/// including starting and stopping the scanning process, and toggling the device's torch.
public class MHScanKit: NSObject {
  
  /// The delegate that receives scanning results.
  ///
  /// Set this property to an object that conforms to `MHScanKitDelegate`
  /// to receive callbacks when a barcode is successfully scanned.
  public weak var delegate: MHScanKitDelegate?
  
  /// The view controller responsible for presenting the scanning interface.
  ///
  /// This property is set when the scanning process is started and cleared when it's stopped.
  private var sheetViewController: MHSKSheetViewController?
  
  /// The delegate that receives error notifications.
  ///
  /// Set this property to an object that conforms to `MHSKErrorDelegate`
  /// to receive callbacks when an error occurs during the scanning process.
  public weak var errorDelegate: MHSKErrorDelegate?
  
  /// Starts the barcode scanning process.
  ///
  /// This method presents a view controller that shows the camera feed and scans for barcodes.
  /// When a barcode is successfully scanned, the `delegate` is notified.
  ///
  /// - Parameter viewController: The view controller from which to present the scanning interface.
  public func start(from viewController: UIViewController) {
    let sheetVC = MHSKSheetViewController()
    sheetVC.onBarcodeScanned = { [weak self] code in
      guard let self = self, let code = code else { return }
      self.delegate?.scanKit(self, didScanBarcode: code)
      self.sheetViewController?.dismiss(animated: true, completion: nil)
    }
    sheetVC.errorHandler = { [weak self] error in
      guard let self = self else { return }
      self.errorDelegate?.scanKit(self, didEncounterError: error)
    }
    viewController.present(sheetVC, animated: true, completion: nil)
    self.sheetViewController = sheetVC
  }
  
  /// Stops the barcode scanning process.
  ///
  /// This method dismisses the scanning interface if it's currently presented.
  public func stop() {
    guard let sheetViewController = sheetViewController else {
      return
    }
    sheetViewController.dismiss(animated: true) {
      self.sheetViewController = nil
    }
  }
  
  /// Toggles the device's torch (flashlight) on or off.
  ///
  /// - Parameter on: A boolean value indicating whether to turn the torch on (`true`) or off (`false`).
  public static func toggleTorch(on: Bool) {
    MHSKDeviceCapabilitiesHelper.toggleTorch(on: on)
  }
}
