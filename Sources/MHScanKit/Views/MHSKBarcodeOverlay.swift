//
//  MHSKBarcodeOverlay.swift
//
//
//  Created by Michael Harrigan on 8/21/24.
//

import SwiftUI

/// A view that overlays a rounded rectangle around the detected barcode.
///
/// This view highlights the detected barcode area on the camera preview.
/// It provides customization options for the overlay's appearance.
struct MHSKBarcodeOverlay: View {
  /// The frame of the detected barcode in the camera preview.
  let barcodeFrame: CGRect?
  
  /// The color of the overlay stroke.
  let strokeColor: Color
  
  /// The color of the overlay background.
  let backgroundColor: Color
  
  /// The width of the overlay stroke.
  let lineWidth: CGFloat
  
  /// The corner radius of the overlay.
  let cornerRadius: CGFloat
  
  /// Initializes a new barcode overlay view.
  ///
  /// - Parameters:
  ///   - barcodeFrame: The frame of the detected barcode.
  ///   - strokeColor: The color of the overlay stroke. Defaults to green.
  ///   - backgroundColor: The color of the overlay background. Defaults to red with 30% opacity.
  ///   - lineWidth: The width of the overlay stroke. Defaults to 3.
  ///   - cornerRadius: The corner radius of the overlay. Defaults to 10.
  init(
    barcodeFrame: CGRect?,
    strokeColor: Color = .green,
    backgroundColor: Color = .red.opacity(0.3),
    lineWidth: CGFloat = 3,
    cornerRadius: CGFloat = 10
  ) {
    self.barcodeFrame = barcodeFrame
    self.strokeColor = strokeColor
    self.backgroundColor = backgroundColor
    self.lineWidth = lineWidth
    self.cornerRadius = cornerRadius
  }
  
  var body: some View {
    GeometryReader { geometry in
      if let frame = barcodeFrame {
        RoundedRectangle(cornerRadius: cornerRadius)
          .stroke(strokeColor, lineWidth: lineWidth)
          .background(RoundedRectangle(cornerRadius: cornerRadius).fill(backgroundColor))
          .frame(width: frame.width, height: frame.height)
          .position(x: frame.midX, y: frame.midY)
      }
    }
    .edgesIgnoringSafeArea(.all)
  }
}
