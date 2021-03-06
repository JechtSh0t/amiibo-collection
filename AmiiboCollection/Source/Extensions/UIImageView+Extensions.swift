//
//  UIImageView+Extensions.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/2/20.
//
import UIKit

// MARK: - Image Loading -

extension UIImageView {
    
    ///
    /// Shows an activity indicator while an image is loading.
    ///
    /// - returns: The activity indicator in progress.
    ///
    func showActivityIndicator() -> UIActivityIndicatorView {
        
        image = nil
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.color = traitCollection.userInterfaceStyle == .light ? .black : .white
        addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    ///
    /// Hides an existing activity indicator.
    ///
    /// - parameter activityIndicator: The indicator to hide.
    ///
    func hideActivityIndicator(_ activityIndicator: UIActivityIndicatorView) {
        
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}
