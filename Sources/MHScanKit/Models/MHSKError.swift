//
//  MHSKError.swift
//  
//
//  Created by Michael Harrigan on 8/30/21.
//
import Foundation

/// The delegate a conforming class will implement to handle
/// any errors thrown in the package.
protocol MHSKErrorDelegate: AnyObject {
    func presentAlertWithMessage(string: String)
}

/// Custom `Error` wrapper so the package can
/// become really specifc with errors.
enum MHSKError: Error {
    
    // Generic error thrown
    case genericError(message: String?)
    
    // For the unknown
    case unexpected(code: Int)
    
    var description: String {
        switch self {
        case .genericError(message: let message):
            return "\(message ?? "No error provided")"
        case .unexpected(code: let code):
            return "Error \(code)"
        }
    }
}
