//
//  Date+Extensions.swift
//  AmiiboCollection
//
//  Created by Phil on 12/7/20.
//

import Foundation

extension Date {
    
    /// Used to decode dates from the Amiibo API.
    static var storageFormatter: DateFormatter {
        let decoder = DateFormatter()
        decoder.dateFormat = "yyyy-MM-dd"
        return decoder
    }
    
    /// Used to display dates in a user-friendly format.
    static var displayFormatter: DateFormatter {
        let encoder = DateFormatter()
        encoder.dateFormat = "MM/dd/yy"
        return encoder
    }
}
