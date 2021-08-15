//
//  MHSKDimView.swift
//
//
//  Created by Michael Harrigan on 8/21/24.
//

import UIKit

/// A view that dims the background to highlight the barcode area.
class MHSKDimView: UIView {
  
  /// Initializes a new instance of the dim view.
  init() {
    super.init(frame: .zero)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  /// Configures the view's appearance and behavior.
  private func setupView() {
    backgroundColor = UIColor.black.withAlphaComponent(0.5)
    translatesAutoresizingMaskIntoConstraints = false
  }
}
