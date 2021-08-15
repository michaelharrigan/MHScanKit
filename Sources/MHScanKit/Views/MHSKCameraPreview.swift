//
//  MHSKCameraPreview.swift
//
//
//  Created by Michael Harrigan on 8/21/24.
//

import SwiftUI
import AVFoundation

/// A UIViewRepresentable struct that provides a camera preview using AVCaptureSession.
struct MHSKCameraPreview: UIViewRepresentable {
  /// The capture session used for the camera preview.
  let session: AVCaptureSession
  
  /// A callback that provides the preview layer to the view model.
  var previewLayerCallback: (AVCaptureVideoPreviewLayer) -> Void
  
  /// Creates and returns a UIView that hosts the camera preview layer.
  ///
  /// - Parameter context: The context in which the view is created.
  /// - Returns: A UIView that displays the camera preview.
  func makeUIView(context: Context) -> UIView {
    let view = UIView(frame: UIScreen.main.bounds)
    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.frame = view.bounds
    previewLayer.videoGravity = .resizeAspectFill
    
    // Set the orientation to portrait
    if let connection = previewLayer.connection, connection.isVideoOrientationSupported {
      connection.videoOrientation = .portrait
    }
    
    view.layer.addSublayer(previewLayer)
    
    previewLayerCallback(previewLayer)
    
    return view
  }
  
  /// Updates the UIView when SwiftUI updates the state.
  ///
  /// This method updates the preview layer's frame when the view is updated,
  /// ensuring that the camera preview adjusts to any view resizing.
  ///
  /// - Parameters:
  ///   - uiView: The UIView to update.
  ///   - context: The context in which the update occurs.
  func updateUIView(_ uiView: UIView, context: Context) {
    if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
      previewLayer.frame = uiView.bounds
    }
  }
}
