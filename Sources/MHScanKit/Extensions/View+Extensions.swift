//
//  View+Extensions.swift
//
//
//  Created by Michael Harrigan on 8/21/24.
//

import SwiftUI

// MARK: - Custom View Modifiers

extension View {
  /// A custom style for control buttons used in the scanning interface.
  ///
  /// - Parameter backgroundColor: The background color of the button.
  /// - Returns: A styled view with circular shape and padding.
  func controlButtonStyle(backgroundColor: Color) -> some View {
    self
      .foregroundColor(.white)
      .padding()
      .background(backgroundColor)
      .clipShape(Circle())
  }
  
  /// A custom style for displaying the scan status message.
  ///
  /// - Parameter backgroundColor: The background color of the status message.
  /// - Returns: A styled view with rounded corners and opacity.
  func scanStatusStyle(backgroundColor: Color) -> some View {
    self
      .foregroundColor(.white)
      .padding()
      .background(backgroundColor.opacity(0.7))
      .cornerRadius(10)
  }
  
  /// Applies a consistent style to the scan status text.
  ///
  /// - Parameters:
  ///   - backgroundColor: The background color of the status message.
  ///   - textColor: The color of the status text.
  /// - Returns: A styled view with padding, background, and corner radius.
  func scanStatusStyle(backgroundColor: Color, textColor: Color) -> some View {
    self
      .padding()
      .background(backgroundColor.opacity(0.7))
      .foregroundColor(textColor)
      .cornerRadius(10)
      .shadow(radius: 5)
  }
}
