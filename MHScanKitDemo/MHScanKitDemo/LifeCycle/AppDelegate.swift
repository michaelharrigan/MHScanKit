//
//  AppDelegate.swift
//  MHScanKitDemo
//
//  Created by Michael Harrigan on 10/28/22.
//
import MHScanKit
import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    self.window = UIWindow(frame: UIScreen.main.bounds)
    let controller = UIHostingController(rootView: MHSKSheetView())
    self.window?.rootViewController = controller
    self.window?.makeKeyAndVisible()
    return true
  }
}
