import SwiftUI

import SwiftUI
import UIKit

/// A view that provides control buttons for the scanning process.
///
/// This view includes buttons to toggle the flashlight, capture the detected barcode, and
/// restart the scanning process. It allows for customization of button colors and sizes.
struct MHSKControlButtonsView: View {
  /// The view model responsible for handling the button actions.
  @ObservedObject var viewModel: MHSKSheetViewModel
  
  /// The color for the toggle torch and restart buttons.
  let primaryButtonColor: Color
  
  /// The color for the capture button.
  let captureButtonColor: Color
  
  /// The size of the buttons.
  let buttonSize: CGFloat
  
  /// A Boolean value indicating whether the capture button is currently visible.
  ///
  /// This state is used to control the visibility and animation of the capture button.
  @State private var isCaptureButtonVisible = false
  
  /// A Boolean value indicating whether the capture button is in the tapped state.
  ///
  /// This state is used to control the scale animation of the capture button when it is tapped.
  @State private var isButtonTapped = false
  
  /// The timestamp of the last tap on the capture button.
  ///
  /// This is used to implement a debounce mechanism, preventing multiple taps in quick succession.
  @State private var lastTapped: Date? = nil
  
  /// Initializes a new control buttons view.
  ///
  /// - Parameters:
  ///   - viewModel: The view model responsible for handling the button actions.
  ///   - primaryButtonColor: The color for the toggle torch and restart buttons. Defaults to blue.
  ///   - captureButtonColor: The color for the capture button. Defaults to green.
  ///   - buttonSize: The size of the buttons. Defaults to 60.
  init(
    viewModel: MHSKSheetViewModel,
    primaryButtonColor: Color = .blue,
    captureButtonColor: Color = .green,
    buttonSize: CGFloat = 60
  ) {
    self.viewModel = viewModel
    self.primaryButtonColor = primaryButtonColor
    self.captureButtonColor = captureButtonColor
    self.buttonSize = buttonSize
  }
  
  var body: some View {
    HStack {
      if MHSKDeviceCapabilitiesHelper.hasTorch() {
        controlButton(
          action: viewModel.toggleTorch,
          imageName: viewModel.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill",
          color: primaryButtonColor
        )
      }
      
      Spacer()
      
      if viewModel.detectedCode != nil {
        controlButton(
          action: captureButtonTapped,
          imageName: "camera.circle.fill",
          color: captureButtonColor
        )
        .scaleEffect(isCaptureButtonVisible ? (isButtonTapped ? 0.9 : 1.2) : 0.0)
        .opacity(isCaptureButtonVisible ? 1.0 : 0.0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: isCaptureButtonVisible)
        .onAppear {
          withAnimation {
            isCaptureButtonVisible = true
          }
        }
      }
      
      Spacer()
      
      controlButton(
        action: viewModel.restartScanning,
        imageName: "arrow.clockwise",
        color: primaryButtonColor
      )
    }
  }
  
  /// Handles the capture button tap action.
  ///
  /// This method triggers the capture code action in the view model, provides haptic feedback,
  /// and controls the animation of the capture button. It includes a debounce mechanism to prevent
  /// rapid, consecutive taps.
  private func captureButtonTapped() {
    let now = Date()
    if let lastTapped = lastTapped, now.timeIntervalSince(lastTapped) < 0.5 {
      // Prevent action if tapped too quickly (debounce)
      return
    }
    
    self.lastTapped = now
    
    // Haptic Feedback
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.prepare()
    generator.impactOccurred()
    
    withAnimation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0)) {
      viewModel.captureCode()
      isButtonTapped = true
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      isButtonTapped = false
    }
  }
  
  /// Creates a control button with the specified action, image, and color.
  ///
  /// - Parameters:
  ///   - action: The action to perform when the button is tapped.
  ///   - imageName: The name of the system image to display on the button.
  ///   - color: The color of the button.
  /// - Returns: A button view configured with the specified parameters.
  private func controlButton(action: @escaping () -> Void, imageName: String, color: Color) -> some View {
    Button(action: action) {
      Image(systemName: imageName)
        .frame(width: buttonSize, height: buttonSize)
        .foregroundColor(.white)
        .background(color)
        .clipShape(Circle())
    }
  }
}
