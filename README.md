# MHScanKit

<img src="https://github.com/michaelharrigan/MHScanKit/blob/master/AppIcon.svg"  height="400" width="400"/>

MHScanKit is a privacy-minded Swift package for scanning QR codes and barcodes in iOS applications. It provides a customizable, SwiftUI-based interface for barcode scanning with a focus on user privacy and ease of integration.

## Features

- Privacy-focused barcode and QR code scanning
- SwiftUI interface with MVVM architecture
- Support for multiple barcode types (EAN-8, EAN-13, PDF417, Code 128)
- Customizable UI components
- Torch (flashlight) control
- Real-time barcode detection and highlighting
- Comprehensive error handling system

## Requirements

- iOS 14.0+
- Swift 5.3+
- Xcode 12.0+

## Installation

### Swift Package Manager

You can install MHScanKit using Swift Package Manager. Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/MHScanKit.git", from: "1.0.0")
]
```

## Usage

1. Import MHScanKit in your SwiftUI view:

```swift
import MHScanKit
```

2. Create an error handler that conforms to `MHSKErrorDelegate`:

```swift
class ScannerErrorHandler: MHSKErrorDelegate {
    func scanKit(didEncounterError error: MHSKError) {
        switch error {
        case .cameraUnavailable:
            print("Camera is not available on this device.")
        case .setupFailed(let underlyingError):
            print("Failed to set up the scanner: \(underlyingError.localizedDescription)")
        case .torchUnavailable:
            print("Torch is not available on this device.")
        case .torchError(let underlyingError):
            print("Failed to toggle torch: \(underlyingError.localizedDescription)")
        case .scanningError(let underlyingError):
            print("An error occurred during scanning: \(underlyingError.localizedDescription)")
        }
    }
}
```

3. Use the `MHSKSheetView` in your SwiftUI view:

```swift
struct ContentView: View {
    @State private var showScanner = false
    @State private var scannedCode: String?
    
    let errorHandler = ScannerErrorHandler()

    var body: some View {
        VStack {
            Button("Scan Barcode") {
                showScanner = true
            }
            if let scannedCode = scannedCode {
                Text("Scanned Code: \(scannedCode)")
            }
        }
        .sheet(isPresented: $showScanner) {
            MHSKSheetView(errorDelegate: errorHandler)
                .onDisappear {
                    if let code = scannedCode {
                        print("Scanned barcode: \(code)")
                    }
                }
        }
    }
}
```

## Error Handling

MHScanKit provides a comprehensive error handling system through the `MHSKErrorDelegate` protocol. This allows you to handle various errors that may occur during the scanning process, such as camera unavailability or torch-related issues.

To handle errors, implement the `MHSKErrorDelegate` protocol and provide it to the `MHSKSheetView`:

```swift
class YourErrorHandler: MHSKErrorDelegate {
    func scanKit(didEncounterError error: MHSKError) {
        // Handle the error here
    }
}

let errorHandler = YourErrorHandler()
MHSKSheetView(errorDelegate: errorHandler)
```

## Customizing the Scanner Appearance

You can customize the appearance of the scanner interface by creating a `MHSKScannerConfiguration` object:

```swift
let customConfig = MHSKScannerConfiguration(
    highlightColor: .red,
    buttonColor: .purple,
    statusBackgroundColor: Color.gray.opacity(0.8),
    statusTextColor: .black
)

MHSKSheetView(configuration: customConfig, errorDelegate: self)
```

## Privacy

MHScanKit is designed with privacy in mind. It processes all barcode data on-device and does not send any scanned information to external servers.

## Roadmap

- [x] Reliably scan a barcode and QR code
- [x] Add UI for the scanning
- [x] Create proper API for outputting basic barcode/QR code information
- [x] Implement comprehensive error handling system
- [ ] Write unit tests for both API and package
- [ ] Add support for custom barcode types
- [ ] Implement localization for broader language support

## Contributing

Contributions to MHScanKit are welcome! Please feel free to submit a Pull Request.

## License

MHScanKit is available under the MIT license. See the LICENSE file for more info.

## Support

If you have any questions or need help integrating MHScanKit, please open an issue on the GitHub repository.

---

Feel free to reach out to me. I will try and update the package as much as I can.
