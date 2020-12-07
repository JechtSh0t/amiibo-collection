//
//  ProgressViewController.swift
//
//  Created by JechtSh0t on 12/2/20.
//
import UIKit

///
/// Ued as a progress indicator for asynchronous operations.
///
final class ProgressViewController: UIViewController {
    
    /// The active indicator, if there is one.
    private var activityIndicator: UIActivityIndicatorView!
    /// The color of the progress indicator.
    var color: UIColor = .black
    
    // MARK: - Setup -
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .large)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        }
        
        activityIndicator.color = color
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(activityIndicator)
        view.addConstraint(NSLayoutConstraint(item: activityIndicator!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: activityIndicator!, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        view.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        activityIndicator.startAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        super.viewDidDisappear(animated)
        activityIndicator.stopAnimating()
    }
}
