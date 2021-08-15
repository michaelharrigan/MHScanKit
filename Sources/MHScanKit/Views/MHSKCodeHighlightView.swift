//
//  File.swift
//  
//
//  Created by Michael Harrigan on 8/21/24.
//

import UIKit

/// A view that highlights the detected barcode by drawing a green border around it.
class MHSKCodeHighlightView: UIView {
  
  /// Initializes a new instance of the code highlight view.
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
    layer.borderColor = UIColor.green.cgColor
    layer.borderWidth = 2.0
    layer.cornerRadius = 10
    clipsToBounds = true
    isHidden = true
    translatesAutoresizingMaskIntoConstraints = false
  }
}
