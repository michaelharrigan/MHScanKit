//
//  HomeViewController.swift
//  MHScanKitDemo
//
//  Created by Michael Harrigan on 10/28/22.
//

import UIKit
import MHScanKit

/// The first controller shown to the user in the demo app.
class HomeViewController: UIViewController {
    
    // MARK: - Properties
    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: .systemFont(ofSize: 48.0, weight: .black))
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = NSLocalizedString("It's really empty in here...? 👀", comment: "It's really empty in here...? 👀")
        return label
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .secondarySystemBackground
        self.view.addSubview(self.mainLabel)
        NSLayoutConstraint.activate([
            self.mainLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.mainLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.mainLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24.0),
            self.mainLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24.0)
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            let scanKit = MHSKViewController()
            let rootController = UINavigationController(rootViewController: scanKit)
            rootController.modalPresentationStyle = .fullScreen
            self.present(rootController, animated: true)
        })
    }
}

