//
//  ErrorHandler.swift
//  MHScanKitDemo
//
//  Created by Michael Harrigan on 8/21/24.
//

import MHScanKit

class ErrorHandler: MHSKErrorDelegate {
  private var parent: HomeView
  
  init(parent: HomeView) {
    self.parent = parent
  }
  
  func scanKit(didEncounterError error: MHSKError) {
    switch error {
    case .cameraUnavailable:
      parent.errorMessage = "Camera is not available on this device."
    case .setupFailed(let underlyingError):
      parent.errorMessage = "Failed to set up the scanner: \(underlyingError.localizedDescription)"
    case .torchUnavailable:
      parent.errorMessage = "Torch is not available on this device."
    case .torchError(let underlyingError):
      parent.errorMessage = "Failed to toggle torch: \(underlyingError.localizedDescription)"
    case .scanningError(let underlyingError):
      parent.errorMessage = "An error occurred during scanning: \(underlyingError.localizedDescription)"
    }
    parent.showScanner = false
  }
}
