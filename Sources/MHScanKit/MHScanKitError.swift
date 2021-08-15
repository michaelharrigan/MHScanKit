//
//  File.swift
//  
//
//  Created by Michael Harrigan on 8/30/21.
//
#if !os(macOS)
import Foundation

internal enum MHScanKitError: Error {
    
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
#endif
