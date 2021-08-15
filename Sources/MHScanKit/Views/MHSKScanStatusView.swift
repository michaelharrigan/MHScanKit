//
//  MHSKScanStatusView.swift
//
//
//  Created by Michael Harrigan on 8/21/24.
//

import SwiftUI

/// A view that displays the current scanning status and the detected barcode.
///
/// This view shows a message indicating whether the scanning is in progress or a barcode
/// has been captured. It allows customization of colors and provides localized strings.
@available(iOS 17.0, *)
struct MHSKScanStatusView: View {
  /// A Boolean value indicating whether the scanner is currently active.
  let isScanning: Bool
  
  /// The code detected during the scanning process.
  let detectedCode: String?
  
  /// The code that has been successfully captured.
  let scannedCode: String?
  
  /// The background color for the scanning status.
  let scanningBackgroundColor: Color
  
  /// The background color for the captured status.
  let capturedBackgroundColor: Color
  
  /// The text color for the status messages.
  let textColor: Color

  /// Tracking whether not not to show copied animation.
  @State private var showCopyAnimation = false
  
  /// Initializes a new scan status view.
  ///
  /// - Parameters:
  ///   - isScanning: A Boolean value indicating whether the scanner is currently active.
  ///   - detectedCode: The code detected during the scanning process.
  ///   - scannedCode: The code that has been successfully captured.
  ///   - scanningBackgroundColor: The background color for the scanning status. Defaults to black.
  ///   - capturedBackgroundColor: The background color for the captured status. Defaults to green.
  ///   - textColor: The text color for the status messages. Defaults to white.
  init(
    isScanning: Bool,
    detectedCode: String?,
    scannedCode: String?,
    scanningBackgroundColor: Color = .black,
    capturedBackgroundColor: Color = .green,
    textColor: Color = .white
  ) {
    self.isScanning = isScanning
    self.detectedCode = detectedCode
    self.scannedCode = scannedCode
    self.scanningBackgroundColor = scanningBackgroundColor
    self.capturedBackgroundColor = capturedBackgroundColor
    self.textColor = textColor
  }
  
  var body: some View {
    Group {
      if isScanning {
        Text(detectedCode ?? NSLocalizedString("Scanning for barcode...", comment: "Scanning status message"))
          .scanStatusStyle(backgroundColor: scanningBackgroundColor, textColor: textColor)
      } else if let code = scannedCode {
        Text(showCopyAnimation ? NSLocalizedString("Copied", comment: "Copied status message") :
              String(format: NSLocalizedString("Captured: %@", comment: "Captured barcode message"), code))
        .bold(showCopyAnimation)
        .scanStatusStyle(backgroundColor: capturedBackgroundColor, textColor: textColor)
        .scaleEffect(showCopyAnimation ? 1.1 : 1.0)
        .animation(.spring(), value: showCopyAnimation)
        .onTapGesture {
          copyToClipboard(code: code)
        }
        .sensoryFeedback(.selection, trigger: showCopyAnimation)
      }
    }
  }
  
  private func copyToClipboard(code: String) {
    UIPasteboard.general.string = code
    showCopyAnimation = true
    
    // Reset animation after a short delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      showCopyAnimation = false
    }
  }
}
