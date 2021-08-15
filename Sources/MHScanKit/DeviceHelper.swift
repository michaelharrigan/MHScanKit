//
//  DeviceHelper.swift
//  The-Sampler
//
//  Created by Michael Harrigan on 8/8/21.
//

import UIKit
import AVFoundation

class MKScanKitDeviceHelper {
    
    static func toggleTorch(on: Bool) {
        
        // Get the current device
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            if device.hasTorch {
            try device.lockForConfiguration()
                device.torchMode = on ? .on : .off
                
                let touchGenerator = UINotificationFeedbackGenerator()
                touchGenerator.notificationOccurred(.success)
                device.unlockForConfiguration()
            }
            
        } catch {
            
        }
    }
}
