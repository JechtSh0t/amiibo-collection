//
//  Date+Extensions.swift
//  AmiiboCollection
//
//  Created by Phil on 12/7/20.
//

import Foundation

extension Date {
    
    static var storageFormatter: DateFormatter {
        let decoder = DateFormatter()
        decoder.dateFormat = "yyyy-MM-dd"
        return decoder
    }
    
    static var displayFormatter: DateFormatter {
        let encoder = DateFormatter()
        encoder.dateFormat = "MM/dd/yy"
        return encoder
    }
}
