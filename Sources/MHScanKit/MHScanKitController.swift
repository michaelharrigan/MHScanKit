//
//  MHScanKitController.swift
//  The-Sampler
//
//  Created by Michael Harrigan on 8/7/21.
//

import UIKit
import Vision
import AVFoundation

protocol MHScanKitDelegate: AnyObject {
    func scanReturnedPayload(payloadString: String?)
}

/**
 Opens a fullscreen view to scan barcodes or QR codes.
 
 - parameter viewController: Takes a `UIViewController` to display the scanning view.
 
 # Notes: #
 1. Best to place this controller in a `UINavigationController`.
 */
public class MHScanKitController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Properties
    lazy var detectBarcodeRequest = VNDetectBarcodesRequest { request, error in
        if error != nil {
            return
        }
        
        self.processClassification(request)
    }
    
    var captureSession = AVCaptureSession()
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer
    var maskLayer = CAShapeLayer()
    weak var delegate: MHScanKitDelegate?
    
    // MARK: - Life Cycle
    public init(viewController: UIViewController) {
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        super.init(nibName: nil, bundle: nil)
        self.addButtonsToView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.captureSession.stopRunning()
    }
    
    public func startFeatureFlow() {
        self.view.backgroundColor = .systemGray
        self.setupCameraLayer()
        self.setupCameraLiveView()
    }
    
    // MARK: - Camera Layer
    private func setupCameraLiveView() {
        let captureOutput = AVCaptureVideoDataOutput()
        captureOutput.videoSettings =
            [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        captureOutput.setSampleBufferDelegate(
            self,
            queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        self.captureSession.addOutput(captureOutput)
        self.configurePreviewLayer()
        self.captureSession.startRunning()
    }
    
    private func setupCameraLayer() {
        
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        
        guard let device = videoDevice,
              let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
              self.captureSession.canAddInput(videoDeviceInput) else {
            self.showAlert(
                withTitle: NSLocalizedString("Cannot Find Camera", comment: "Cannot Find Camera"),
                message: NSLocalizedString("There seems to be a problem with the camera on your device.", comment: "There seems to be a problem with the camera on your device."))
            return
        }
        
        self.captureSession.addInput(videoDeviceInput)
    }
    
    private func configurePreviewLayer() {
        self.cameraPreviewLayer.videoGravity = .resizeAspectFill
        self.cameraPreviewLayer.connection?.videoOrientation = .portrait
        self.cameraPreviewLayer.frame = self.view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer, at: 0)
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        self.detectRectangle(in: pixelBuffer)
        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .right)
        
        do {
            try imageRequestHandler.perform([detectBarcodeRequest])
        } catch {
            return
        }
    }
    
    
    // MARK: - Vision Processing
    func processClassification(_ request: VNRequest) {
        guard let barcodes = request.results else { return }
        DispatchQueue.main.async {
            if self.captureSession.isRunning {
                for barcode in barcodes {
                    guard let potentialQRCode = barcode as? VNBarcodeObservation else { return }
                    guard let firstBox = barcode as? VNRectangleObservation else { return }
                    self.drawBoundingBox(rect: firstBox)
                    self.captureSession.stopRunning()
                    self.showAlert(
                        withTitle: potentialQRCode.symbology.rawValue,
                        message: String(potentialQRCode.confidence) + " " + (potentialQRCode.payloadStringValue ?? "" ))
                    self.scanReturnedProcessor(payload: potentialQRCode.payloadStringValue)
                    return
                }
            }
        }
    }
    
    private func detectRectangle(in image: CVPixelBuffer) {
        
        let request = VNDetectRectanglesRequest { request, error in
            DispatchQueue.main.async {
                self.maskLayer.removeFromSuperlayer()
                guard let results = request.results as? [VNRectangleObservation] else { return }
                
                guard let rect = results.first else{ return }
                self.drawBoundingBox(rect: rect)
            }
        }
        
        request.minimumAspectRatio = VNAspectRatio(1.3)
        request.maximumAspectRatio = VNAspectRatio(1.6)
        request.minimumSize = Float(0.5)
        request.maximumObservations = 1
        
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        try? imageRequestHandler.perform([request])
    }
    
    func drawBoundingBox(rect : VNRectangleObservation) {
        
        let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -self.cameraPreviewLayer.frame.height)
        let scale = CGAffineTransform.identity.scaledBy(x: self.cameraPreviewLayer.frame.width, y: self.cameraPreviewLayer.frame.height)
        let bounds = rect.boundingBox.applying(scale).applying(transform)
        self.createLayer(in: bounds)
    }
    
    private func createLayer(in rect: CGRect) {
        self.maskLayer.frame = rect
        self.maskLayer.cornerRadius = 12
        self.maskLayer.opacity = 0.75
        self.maskLayer.borderColor = UIColor.red.cgColor
        self.maskLayer.borderWidth = 2.0
        
        self.cameraPreviewLayer.insertSublayer(maskLayer, at: 1)
    }
    
    func scanReturnedProcessor(payload: String?) {
        delegate?.scanReturnedPayload(payloadString: payload)
    }
    
    // MARK: - Button Actions
    private func addButtonsToView() {
        let flashlightButton = SamplerButton(frame: .zero)
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        flashlightButton.translatesAutoresizingMaskIntoConstraints = false
        flashlightButton.setImage(UIImage(systemName: "bolt", withConfiguration: config), for: .normal)
        flashlightButton.setImage(UIImage(systemName: "bolt.fill", withConfiguration: config), for: .selected)
        flashlightButton.backgroundColor = .secondarySystemBackground
        flashlightButton.layer.cornerRadius = 25.0
        flashlightButton.addTarget(self, action: #selector(lightButton), for: .touchUpInside)
        
        let scanListButton = SamplerButton(frame: .zero)
        scanListButton.translatesAutoresizingMaskIntoConstraints = false
        scanListButton.setImage(UIImage(systemName: "list.bullet", withConfiguration: config), for: .normal)
        scanListButton.backgroundColor = .secondarySystemBackground
        scanListButton.layer.cornerRadius = 25.0
        scanListButton.addTarget(self, action: #selector(scanListButtonAction), for: .touchUpInside)
        
        self.view.addSubview(flashlightButton)
        self.view.addSubview(scanListButton)
        NSLayoutConstraint.activate([
            flashlightButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 24.0),
            flashlightButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24.0),
            flashlightButton.heightAnchor.constraint(equalToConstant: 52.0),
            flashlightButton.widthAnchor.constraint(equalToConstant: 52.0),
            
            scanListButton.topAnchor.constraint(equalTo: flashlightButton.topAnchor),
            scanListButton.trailingAnchor.constraint(equalTo: flashlightButton.leadingAnchor, constant: -16.0),
            scanListButton.heightAnchor.constraint(equalToConstant: 52.0),
            scanListButton.widthAnchor.constraint(equalToConstant: 52.0),
        ])
    }
    
    @objc
    func lightButton(sender : SamplerButton) {
        sender.isSelected.toggle()
        MKScanKitDeviceHelper.toggleTorch(on: sender.isSelected)
    }
    
    @objc
    func scanListButtonAction(sender : SamplerButton) {
        sender.isSelected.toggle()
 
    }
    
    // MARK: - Alert Location
    private func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default, handler: { _ in
                self.captureSession.startRunning()
            }))
            self.present(alertController, animated: true)
        }
    }
    
    private func showPermissionsAlert() {
        self.showAlert(
            withTitle: NSLocalizedString("Camera Permissions", comment: "Camera Permissions"),
            message: NSLocalizedString("Please open Settings and grant permission for this app to use your camera.", comment: "Please open Settings and grant permission for this app to use your camera."))
    }
}

// MARK: - Custom Button
class SamplerButton: UIButton {
    override var isSelected: Bool {
        willSet {
            print("changing from \(isSelected) to \(newValue)")
        }
        
        didSet {
            print("changed from \(oldValue) to \(isSelected)")
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}