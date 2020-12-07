//
//  AmiiboDetailsViewController.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/3/20.
//

import UIKit

// MARK: - Delegate -

protocol AmiiboDetailsViewControllerDelegate: class {
    
    /// Called right before *AmiiboDetailsViewController* is dismissed.
    func amiiboDetailsViewControllerWillDismiss(_ viewController: AmiiboDetailsViewController)
}

// MARK: - Class -

final class AmiiboDetailsViewController: BaseViewController {
    
    // MARK: - Properties -
    
    private var amiibo: Amiibo!
    private var isPurchased: Bool { return amiibo.purchase != nil }
    private weak var delegate: AmiiboDetailsViewControllerDelegate?
    
    // MARK: - UI -
    
    @IBOutlet private weak var popoverView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var purchaseIndicatorView: IndicatorView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var gameSeriesLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    
    // MARK: - Setup -
    
    func configure(for amiibo: Amiibo, delegate: AmiiboDetailsViewControllerDelegate?) {
        
        self.amiibo = amiibo
        self.delegate = delegate
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageView.image = ImageManager.shared.loadImage(amiibo.imageSource)
        if isPurchased { purchaseIndicatorView.show(.checkmark, color: .nintendoGreen, backgroundColor: .clear, animated: false) }
        nameLabel.text = amiibo.name
        gameSeriesLabel.text = amiibo.gameSeries
        releaseDateLabel.text = "Released: \(amiibo.northAmericaRelease)"
        
        actionButton.setTitle(!isPurchased ? "Add to Collection" : "Remove", for: .normal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    override func style() {
        
        super.style()
     
        popoverView.roundCorners()
        
        let buttonColor: UIColor = !isPurchased ? .nintendoGreen : .nintendoRed
        actionButton.addBorder(width: 3.0, color: buttonColor)
        actionButton.roundCorners()
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        actionButton.setTitleColor(buttonColor, for: .normal)
    }
}

// MARK: - Transition -

extension AmiiboDetailsViewController: UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        BounceAnimationController()
    }
    
    @objc private func handleTap() {
        
        delegate?.amiiboDetailsViewControllerWillDismiss(self)
        dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == view
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        FadeOutAnimationController()
    }
}

// MARK: - Purchase -

extension AmiiboDetailsViewController {
    
    @IBAction private func actionButtonPressed(_ sender: UIButton) {
        isPurchased ? returnAmiibo() : purchaseAmiibo()
    }
    
    ///
    /// Adds amiibo to the purchase collection.
    ///
    private func purchaseAmiibo() {
        
        do {
            try AmiiboManager.shared.purchase(amiibo)
            purchaseIndicatorView.show(.checkmark, color: .nintendoGreen, backgroundColor: .clear, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                
                self.delegate?.amiiboDetailsViewControllerWillDismiss(self)
                self.dismiss(animated: true, completion: nil)
            })
        } catch {
            showAlert(for: error)
        }
    }
    
    ///
    /// Removes amiibo from the purchase collection.
    ///
    private func returnAmiibo() {
        
        do {
            
            try AmiiboManager.shared.refund(amiibo)
            purchaseIndicatorView.hide()
            purchaseIndicatorView.show(.xmark, color: .nintendoRed, backgroundColor: .clear, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                
                self.delegate?.amiiboDetailsViewControllerWillDismiss(self)
                self.dismiss(animated: true, completion: nil)
            })
        } catch {
            showAlert(for: error)
        }
    }
}
