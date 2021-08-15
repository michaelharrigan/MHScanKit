//
//  MHSKSheetViewController.swift
//  
//
//  Created by Michael Harrigan on 10/28/22.
//

import UIKit

protocol MHSKSheetViewControllerDelegate: AnyObject {
    func sheetControllerActionOccured(buttonType: MHSKSheetViewController.ButtonType)
}

class MHSKSheetViewController: UIViewController {

    enum ButtonType {
        case scan, dismiss, help
    }
    
    private lazy var sendButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Securely Scan", for: .normal)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.addTarget(self, action: #selector(sendAction), for: .touchUpInside)
        button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
        var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 24.0, weight: .semibold)
        return outgoing
     }
        return button
    }()

    private lazy var recieveButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Help", for: .normal)
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
        var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 24.0, weight: .semibold)
        return outgoing
     }
        return button
    }()

    private lazy var helpButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Dismiss", for: .normal)
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        button.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
        var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 24.0, weight: .semibold)
        return outgoing
     }
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16.0
        return stackView
    }()

    private lazy var mainLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        let fontMetrics = UIFontMetrics(forTextStyle: .title1)
        label.font = fontMetrics.scaledFont(for: .systemFont(ofSize: 32.0, weight: .bold))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        label.text = NSLocalizedString("Scanning?", comment: "Scanning?")
        return label
    }()

    weak var delegate: MHSKSheetViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground

        self.view.addSubview(stackView)
        self.stackView.addArrangedSubview(mainLabel)
        self.stackView.addArrangedSubview(sendButton)
        self.stackView.addArrangedSubview(recieveButton)
        self.stackView.addArrangedSubview(helpButton)
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16.0),
            self.stackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16.0),
            self.stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16.0),
            self.stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16.0)
        ])
    }

    @objc func sendAction() {
        self.delegate?.sheetControllerActionOccured(buttonType: .scan)
    }
}

