//
//  MHSKError.swift
//
//
//  Created by Michael Harrigan on 8/21/24.
//
import Foundation

public enum MHSKError: Error {
  case cameraUnavailable
  case setupFailed(Error)
  case torchUnavailable
  case torchError(Error)
  case scanningError(Error)
}

public protocol MHSKErrorDelegate: AnyObject {
  /// Called when an error occurs during the scanning process.
  ///
  /// - Parameter error: The error that occurred during scanning.
  func scanKit(didEncounterError error: MHSKError)
}
