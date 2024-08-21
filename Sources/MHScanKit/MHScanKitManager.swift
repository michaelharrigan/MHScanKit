//
//  MHScanKitManager.swift
//  
//
//  Created by Michael Harrigan on 10/28/22.
//

import UIKit
import SwiftUI

@available(iOS 14.0, *)
public class MHScanKitManager {
  public static func startScanKit() -> UIViewController {
    return UIHostingController(rootView: MHSKSheetView())
  }
}
