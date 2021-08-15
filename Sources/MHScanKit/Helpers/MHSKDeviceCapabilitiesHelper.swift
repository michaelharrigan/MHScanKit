//
//  MHSKDeviceCapabilitiesHelper.swift
//  MHScanKitDemo.app
//
//  Created by Michael Harrigan on 8/8/21.
//
import UIKit
import AVFoundation

/// A helper class for managing device-specific capabilities.
public class MHSKDeviceCapabilitiesHelper {
  
  /// Toggles the device's torch (flashlight) on or off.
  ///
  /// - Parameters:
  ///   - on: A boolean value indicating whether to turn the torch on (`true`) or off (`false`).
  ///   - level: The brightness level of the torch, ranging from 0.0 to 1.0. Defaults to 0.8.
  ///
  /// - Throws: `MHSKError.torchUnavailable` if the device doesn't have a torch.
  ///           `MHSKError.torchError` if there's an error toggling the torch.
  public static func toggleTorch(on: Bool, level: Float = 0.8) throws {
    let touchGenerator = UINotificationFeedbackGenerator()
    touchGenerator.prepare()
    
    guard let device = AVCaptureDevice.default(for: .video) else {
      throw MHSKError.torchUnavailable
    }
    
    guard device.hasTorch else {
      throw MHSKError.torchUnavailable
    }
    
    do {
      try device.lockForConfiguration()
      
      if on {
        try device.setTorchModeOn(level: level)
      } else {
        device.torchMode = .off
      }
      
      touchGenerator.notificationOccurred(.success)
      device.unlockForConfiguration()
    } catch {
      throw MHSKError.torchError(error)
    }
  }
  
  /// Checks if the device has a torch (flashlight) capability.
  ///
  /// - Returns: A boolean value indicating whether the device has a torch.
  public static func hasTorch() -> Bool {
    guard let device = AVCaptureDevice.default(for: .video) else {
      return false
    }
    return device.hasTorch
  }
}
