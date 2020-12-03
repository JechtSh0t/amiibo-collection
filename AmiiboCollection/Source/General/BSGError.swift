//
//  BSGError.swift
//
//  Created by JechtSh0t on 7/4/20.
//  Copyright © 2020 Brook Street Games. All rights reserved.
//
import Foundation

///
/// Combines all relevant information about an error.
///
struct BSGError: LocalizedError, CustomStringConvertible {
    
    // MARK: - Public Properties -
    
    /// A general category that can be used to handle groups of errors in the same manner.
    var type: ErrorType
    /// Specific information related to an individual error. This can be different among error of the same *type*.
    var additionalInfo: String?
    /// A user friendly description of the error, combining the *type* and *additionalInfo* values.
    var errorDescription: String? {
        
        var description = type.rawValue
        if let additionalInfo = additionalInfo { description += ": \(additionalInfo)" }
        return description
    }
    
    var description: String { errorDescription ?? "" }
}

// MARK: - Nested Types -

extension BSGError {
    
    /// Covers all categories of error that can be thrown by Brook Street Games.
    enum ErrorType: String {
        
        case network = "Network Issue"
        case data = "Data Issue"
        case casting = "Casting Issue"
        case permission = "Permission Issue"
        case input = "Input Issue"
    }
}
