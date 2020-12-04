//
//  BaseViewController.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/2/20.
//
import UIKit

///
/// Contains base functionality for all View Controllers.
///
class BaseViewController: UIViewController {
    
    // MARK: - Properties -
        
    /// Active progress indicator.
    private var progressViewController: ProgressViewController?
    
    // MARK: - Setup -
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        style()
    }
    
    ///
    /// Style adjustments.
    ///
    func style() {
        traitCollection.userInterfaceStyle == .light ? lightStyle() : darkStyle()
    }
    
    ///
    /// Style adjustments exclusive to light mode.
    ///
    func lightStyle() {}
    
    ///
    /// Style adjustments exclusive to dark mode.
    ///
    func darkStyle() {}
}

// MARK: - Interface Style Change -

extension BaseViewController {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        style()
    }
}

// MARK: - Progress Indicator -
extension BaseViewController {
    
    ///
    /// Displays progress indicator in center of screen, if it is not already active.
    ///
    func showProgress() {
        
        guard progressViewController == nil else { return }
        let progressViewController = ProgressViewController()
        progressViewController.modalPresentationStyle = .overCurrentContext
        present(progressViewController, animated: false, completion: nil)
        self.progressViewController = progressViewController
    }
    
    ///
    /// Hides an active progress indicator.
    ///
    func hideProgress() {
        progressViewController?.dismiss(animated: false, completion: nil)
        progressViewController = nil
    }
}

// MARK: - Error -
extension BaseViewController {
    
    ///
    /// Displays an alert for an error.
    ///
    /// - parameter error: The error to show alert for.
    ///
    func showAlert(for error: Error) {
        
        hideProgress()
        
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
