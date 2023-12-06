//
//  MHSKDeviceCapabilitiesHelper.swift
//  MHScanKitDemo.app
//
//  Created by Michael Harrigan on 8/8/21.
//

import UIKit
import AVFoundation

/// Helper class to work with all the different
/// capabilties a user's device may have or not.
class MHSKDeviceCapabilitiesHelper {
  
  /// This function will toggle the user's
  /// torch (camera light) on their device.
  static func toggleTorch(on: Bool) {
    // Set up and prepare
    // the haptic feedback
    let touchGenerator = UINotificationFeedbackGenerator()
    touchGenerator.prepare()
    
    // Get the current device
    guard let device = AVCaptureDevice.default(for: .video) else { return }
    
    do {
      // If the device has a torch,
      // we try to lock it for config,
      // so nothing else interferes with it.
      if device.hasTorch {
        try device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        try device.setTorchModeOn(level: 0.80)
        touchGenerator.notificationOccurred(.success)
        device.unlockForConfiguration()
      }
    } catch { assertionFailure(String(describing: error)) }
  }
}
