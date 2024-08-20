//
//  MHSKDeviceCapabilitiesHelper.swift
//  MHScanKitDemo.app
//
//  Created by Michael Harrigan on 8/8/21.
//

import UIKit
import AVFoundation

public class MHSKDeviceCapabilitiesHelper {
  public static func toggleTorch(on: Bool) {
    let touchGenerator = UINotificationFeedbackGenerator()
    touchGenerator.prepare()
    
    guard let device = AVCaptureDevice.default(for: .video) else { return }
    
    do {
      if device.hasTorch {
        try device.lockForConfiguration()
        device.torchMode = on ? .on : .off
        try device.setTorchModeOn(level: 0.80)
        touchGenerator.notificationOccurred(.success)
        device.unlockForConfiguration()
      }
    } catch {
      print("Error toggling torch: \(error)")
    }
  }
}
