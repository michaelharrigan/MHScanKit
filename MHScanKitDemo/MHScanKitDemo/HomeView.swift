// HomeView.swift
import MHScanKit
import SwiftUI

struct HomeView: View {
  @State var showScanner = false
  @State var scannedCode: String?
  @State var errorMessage: String?
  
  var body: some View {
    VStack(spacing: 20) {
      Text("MHScanKit Demo")
        .font(.largeTitle)
      
      Button("Scan Barcode") {
        showScanner = true
      }
      .padding()
      .background(Color.blue)
      .foregroundColor(.white)
      .cornerRadius(10)
      
      if let scannedCode = scannedCode {
        Text("Scanned Code: \(scannedCode)")
          .padding()
          .background(Color.green.opacity(0.2))
          .cornerRadius(10)
      }
      
      if let errorMessage = errorMessage {
        Text("Error: \(errorMessage)")
          .padding()
          .background(Color.red.opacity(0.2))
          .cornerRadius(10)
      }
    }
    .sheet(isPresented: $showScanner) {
      MHSKSheetView(errorDelegate: ErrorHandler(parent: self))
        .onDisappear {
          if let code = scannedCode {
            print("Scanned barcode: \(code)")
          }
        }
    }
  }
}
