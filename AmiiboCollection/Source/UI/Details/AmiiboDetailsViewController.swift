//
//  AmiiboDetailsViewController.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/3/20.
//

import UIKit

// MARK: - Delegate -

protocol AmiiboDetailsViewControllerDelegate: class {
    
    /// Called when *AmiiboDetailsViewController* is dismissed.
    func amiiboDetailsViewControllerWillDismiss(_ viewController: AmiiboDetailsViewController)
}

// MARK: - Class -

final class AmiiboDetailsViewController: PopoverViewController {
    
    // MARK: - Properties -
    
    private var amiibo: Amiibo!
    private var isPurchased: Bool { return amiibo.purchase != nil }
    private weak var delegate: AmiiboDetailsViewControllerDelegate?
    
    // MARK: - UI -
    
    @IBOutlet private weak var popoverView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    private var activityIndicator: UIActivityIndicatorView?
    @IBOutlet private weak var purchaseIndicatorView: IndicatorView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var gameSeriesLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    
    // MARK: - Setup -
    
    func configure(for amiibo: Amiibo, delegate: AmiiboDetailsViewControllerDelegate?) {
        
        self.amiibo = amiibo
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let imageSource = amiibo.imageSource {
            
            if let cachedImage = ImageManager.shared.loadImage(imageSource) {
                imageView.image = cachedImage
            } else {
                activityIndicator = imageView.showActivityIndicator(style: .medium)
            }
        } else {
            let defaultImageName = traitCollection.userInterfaceStyle == .light ? "amiibo-logo-light" : "amiibo-logo-dark"
            imageView.image = UIImage(named: defaultImageName)
        }
        
        if isPurchased { purchaseIndicatorView.show(.checkmark, color: .nintendoGreen, backgroundColor: .clear, animated: false) }
        nameLabel.text = amiibo.name
        gameSeriesLabel.text = amiibo.gameSeries
        releaseDateLabel.text = "Released: \(amiibo.northAmericaRelease)"
        
        actionButton.setTitle(!isPurchased ? "Add to Collection" : "Remove", for: .normal)
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

extension AmiiboDetailsViewController {

    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.delegate?.amiiboDetailsViewControllerWillDismiss(self)
    }
}

// MARK: - Image Loading -

extension AmiiboDetailsViewController {
    
    ///
    /// Called when *ImageManager* has found an image. If the image url matches the one for this cell, it will be used.
    ///
    @objc private func imageLoaded(_ notification: Notification) {
        
        guard let source = notification.userInfo?["source"] as? URL, source == amiibo.imageSource else { return }
        
        if let image = notification.userInfo?["image"] as? UIImage {
            imageView.image = image
        }
        
        if let activityIndicator = activityIndicator {
            imageView.hideActivityIndicator(activityIndicator)
        }
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
            try AmiiboManager.shared.addToCollection(amiibo)
            purchaseIndicatorView.show(.checkmark, color: .nintendoGreen, backgroundColor: .clear, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8, execute: {
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
            
            try AmiiboManager.shared.removeFromCollection(amiibo)
            purchaseIndicatorView.hide()
            purchaseIndicatorView.show(.xmark, color: .nintendoRed, backgroundColor: .clear, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        } catch {
            showAlert(for: error)
        }
    }
}
