//
//  IndicatorView.swift
//
//  Created by JechtSh0t on 6/11/20.
//  Copyright © 2020 Brook Street Games. All rights reserved.
//

import UIKit

///
/// View that animated in to display a symbol to the user.
///
class IndicatorView: UIView {
    
    private var checkImageView: UIImageView?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        isHidden = true
    }
    
    ///
    /// Shows the view, configured for the desired symbol.
    ///
    /// - parameter symbol: The symbol to display in the view.
    /// - parameter color: The color of the symbol.
    /// - parameter backgroundColor: The color of the rest of the view behind the symbol.
    /// - parameter animated: If true, the view will bounce in.
    ///
    func show(_ symbol: Symbol = .checkmark, color: UIColor = .green, backgroundColor: UIColor = .white, animated: Bool) {
        
        self.backgroundColor = backgroundColor
        isHidden = false
        layer.cornerRadius = bounds.width * 0.20
        
        let checkImageView = UIImageView(image: symbol.image)
        checkImageView.tintColor = color
        addSubview(checkImageView)
        self.checkImageView = checkImageView
        
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: checkImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: checkImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: checkImageView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.9, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: checkImageView, attribute: .height, relatedBy: .equal, toItem: checkImageView, attribute: .width, multiplier: 1.0, constant: 0.0))
        
        if animated {
            
            checkImageView.alpha = 0
            checkImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            superview?.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                checkImageView.alpha = 1
                checkImageView.transform = CGAffineTransform.identity
                self.superview?.isUserInteractionEnabled = true
            })
        }
    }
    
    ///
    /// Hides the view.
    ///
    func hide() {
        
        isHidden = true
        checkImageView?.removeFromSuperview()
        checkImageView = nil
    }
}

// MARK: - Nested Types -

extension IndicatorView {
    
    enum Symbol {
        case checkmark
        case xmark
        
        var image: UIImage {
            switch self {
            case .checkmark: return UIImage(systemName: "checkmark.circle")!
            case .xmark: return  UIImage(systemName: "xmark.circle")!
            }
        }
    }
}
