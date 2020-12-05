//
//  UIButton+Extensions.swift
//  AmiiboCollection
//
//  Created by Phil on 12/4/20.
//

import UIKit

extension UIView {
    
    ///
    /// Rounds corners an amount based on the size of the view.
    ///
    func roundCorners() {
        
        clipsToBounds = true
        layer.cornerRadius = bounds.width * 0.05
    }
    
    ///
    /// Add a border to the view.
    ///
    /// - parameter width: The thickness of the border in points.
    /// - parameter color: The color of the border.
    ///
    func addBorder(width: CGFloat, color: UIColor) {
        
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
}
