//
//  MHSKViewController.swift
//  The-Sampler
//
//  Created by Michael Harrigan on 8/7/21.
//
import UIKit

/// A fullscreen `UIViewController` to scan barcodes or QR codes.
public class MHSKViewController: UIViewController, MHSKSheetViewControllerDelegate {
    
    // MARK: - Properties
    let sheetViewController = MHSKSheetViewController()

    // MARK: - LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemPink
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.sheetViewController.delegate = self
            self.sheetViewController.isModalInPresentation = true
            if let sheetController = self.sheetViewController.sheetPresentationController {
                sheetController.detents = [.medium(), .large()]
                sheetController.preferredCornerRadius = 12
                sheetController.prefersGrabberVisible = true
            }
            self.present(self.sheetViewController, animated: true)
        }
    }
    
    func sheetControllerActionOccured(buttonType: MHSKSheetViewController.ButtonType) {
        switch buttonType { case .scan, .dismiss, .help: break }
    }
}
