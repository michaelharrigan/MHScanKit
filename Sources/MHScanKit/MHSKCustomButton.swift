//
//  File.swift
//  
//
//  Created by Michael Harrigan on 8/14/21.
//

import UIKit


class MHSKCustomButton: UIButton {
    override var isSelected: Bool {
        willSet {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator.selectionChanged()
        }
        
        didSet {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}
