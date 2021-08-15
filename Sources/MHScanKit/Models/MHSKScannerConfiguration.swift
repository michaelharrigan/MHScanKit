//
//  MHSKScannerConfiguration.swift
//
//
//  Created by Michael Harrigan on 8/21/24.
//

import SwiftUI

/// Configuration options for customizing the appearance of the barcode scanning interface.
public struct MHSKScannerConfiguration {
  /// The color of the barcode highlight overlay.
  public let highlightColor: Color
  
  /// The color of the control buttons.
  public let buttonColor: Color
  
  /// The background color of the status view.
  public let statusBackgroundColor: Color
  
  /// The text color for the status view.
  public let statusTextColor: Color
  
  /// The color behind the text with the captured data.
  public let capturedBackgroundColor: Color
  
  /// The color for the capture button.
  public let captureButtonColor: Color
  
  /// The size of the control buttons.
  public let buttonSize: CGFloat
  
  /// Creates a new scanner configuration with custom colors.
  ///
  /// - Parameters:
  ///   - highlightColor: The color of the barcode highlight overlay. Defaults to green.
  ///   - buttonColor: The color of the control buttons. Defaults to blue.
  ///   - statusBackgroundColor: The background color of the status view. Defaults to black with 70% opacity.
  ///   - statusTextColor: The text color for the status view. Defaults to white.
  public init(
    highlightColor: Color = .green,
    buttonColor: Color = .blue,
    statusBackgroundColor: Color = Color.black.opacity(0.7),
    statusTextColor: Color = .white,
    capturedBackgroundColor: Color = Color.black.opacity(0.7),
    captureButtonColor: Color = .green,
    buttonSize: CGFloat = 60
  ) {
    self.highlightColor = highlightColor
    self.buttonColor = buttonColor
    self.statusBackgroundColor = statusBackgroundColor
    self.statusTextColor = statusTextColor
    self.capturedBackgroundColor = capturedBackgroundColor
    self.captureButtonColor = captureButtonColor
    self.buttonSize = buttonSize
  }
}
