//
//  HudView.swift
//  my-locations
//
//  Created by Phil on 6/11/20.
//  Copyright © 2020 Phil Rattazzi. All rights reserved.
//

import UIKit

class CheckmarkView: UIView {
    
    private var checkImageView: UIImageView?
    
    func show(color: UIColor = .green, backgroundColor: UIColor = .white, animated: Bool) {
        
        self.backgroundColor = backgroundColor
        layer.cornerRadius = 10.0
        
        let checkImageView = UIImageView(image: UIImage(systemName: "checkmark.circle"))
        checkImageView.tintColor = color
        addSubview(checkImageView)
        self.checkImageView = checkImageView
        
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: checkImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: checkImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: checkImageView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.8, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: checkImageView, attribute: .height, relatedBy: .equal, toItem: checkImageView, attribute: .width, multiplier: 1.0, constant: 0.0))
        
        if animated {
            checkImageView.alpha = 0
            checkImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                checkImageView.alpha = 1
                checkImageView.transform = CGAffineTransform.identity
            })
        }
    }
    
    func hide() {
        superview?.isUserInteractionEnabled = true
        removeFromSuperview()
    }
}
