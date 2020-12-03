//
//  UIColor+Extensions.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/2/20.
//

import UIKit

// MARK: - Colors -

extension UIColor {
    
    static var base: UIColor { return try! UIColor.color(withHexValue: "#ffffff") }
    static var tint1: UIColor { return try! UIColor.color(withHexValue: "#ffffff") }
    static var tint2: UIColor { return try! UIColor.color(withHexValue: "#ffffff") }
    static var tint3: UIColor { return try! UIColor.color(withHexValue: "#ffffff") }
    static var shade1: UIColor { return try! UIColor.color(withHexValue: "#ffffff") }
    static var shade2: UIColor { return try! UIColor.color(withHexValue: "#ffffff") }
    static var shade3: UIColor { return try! UIColor.color(withHexValue: "#ffffff") }
    
    static var complement: UIColor { return try! UIColor.color(withHexValue: "#ffffff") }
    static var triad1: UIColor { return try! UIColor.color(withHexValue: "#ffffff") }
    static var triad2: UIColor { return try! UIColor.color(withHexValue: "#ffffff") }
    static var triad2Faded: UIColor { return try! UIColor.color(withHexValue: "#ffffff", alpha: 0.5) }
}

// MARK: - Hex -

extension UIColor {
    
    ///
    /// Creates a UIColor object from a hex value.
    ///
    /// - parameter hex: Hex value to create a color from.
    /// - returns: A UIColor built from hex value.
    ///
    static func color(withHexValue hex: String, alpha: CGFloat = 1.0) throws -> UIColor {
        
        let r, g, b: CGFloat
        
        guard hex.hasPrefix("#") else { throw BSGError(type: .data) }
        
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        
        guard hexColor.count == 6 else { throw BSGError(type: .data) }
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        guard scanner.scanHexInt64(&hexNumber) else { throw BSGError(type: .data) }
        
        r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
        g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
        b = CGFloat(hexNumber & 0x0000ff) / 255
        
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}
