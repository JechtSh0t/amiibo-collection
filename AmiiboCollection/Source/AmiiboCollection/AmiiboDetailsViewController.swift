//
//  AmiiboDetailsViewController.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/3/20.
//

import UIKit

// MARK: - Delegate -

protocol AmiiboDetailsViewControllerDelegate: class {
    
    func amiiboDetailsViewControllerDidExit(_ viewController: AmiiboDetailsViewController)
}

// MARK: - Class -

final class AmiiboDetailsViewController: BaseViewController {
    
    // MARK: - Properties -
    
    private var amiibo: AmiiboManager.Amiibo!
    private weak var delegate: AmiiboDetailsViewControllerDelegate?
    
    // MARK: - UI -
    
    @IBOutlet private weak var popoverView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var checkmarkView: CheckmarkView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var gameSeriesLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    
    // MARK: - Setup -
    
    func configure(for amiibo: AmiiboManager.Amiibo, delegate: AmiiboDetailsViewControllerDelegate?) {
        
        self.amiibo = amiibo
        self.delegate = delegate
        
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        imageView.image = ImageManager.shared.loadImage(amiibo.imageSource)
        nameLabel.text = amiibo.name
        gameSeriesLabel.text = amiibo.gameSeries
        releaseDateLabel.text = "Released: \(amiibo.northAmericaRelease)"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    override func style() {
        
        super.style()
     
        popoverView.roundCorners()
        
        actionButton.addBorder(width: 3.0, color: .nintendoGreen)
        actionButton.roundCorners()
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        actionButton.setTitleColor(.nintendoGreen, for: .normal)
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
        
        delegate?.amiiboDetailsViewControllerDidExit(self)
        dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == view
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        FadeOutAnimationController()
    }
}

// MARK: - Actions -

extension AmiiboDetailsViewController {
    
    @IBAction private func actionButtonPressed(_ sender: UIButton) {
        
        checkmarkView.show(color: .nintendoGreen, backgroundColor: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.6), animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
            
            self.delegate?.amiiboDetailsViewControllerDidExit(self)
            self.dismiss(animated: true, completion: nil)
        })
    }
}
