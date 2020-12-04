//
//  UIButton+Extensions.swift
//  AmiiboCollection
//
//  Created by Phil on 12/4/20.
//

import UIKit

extension UIView {
    
    func roundCorners() {
        layer.cornerRadius = bounds.width * 0.05
    }
    
    func addBorder(width: CGFloat, color: UIColor) {
        
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
}
