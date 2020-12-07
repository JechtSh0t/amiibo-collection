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

///
/// Displays a detailed view of a single Amiibo. Allows user to add or remove the Amiibo from the collection.
///
final class AmiiboDetailsViewController: PopoverViewController {
    
    // MARK: - Properties -
    
    /// The single Amiibo that the cell is configured to display.
    private var amiibo: Amiibo!
    /// True, if the Amiibo is already part of the collection.
    private var isPurchased: Bool { return amiibo.purchase != nil }
    /// Reference to *AmiiboCollectionViewController*.
    private weak var delegate: AmiiboDetailsViewControllerDelegate?
    
    // MARK: - UI -
    
    /// Containing view for the popover.
    @IBOutlet private weak var popoverView: UIView!
    /// Displays an image of the Amiibo.
    @IBOutlet private weak var imageView: UIImageView!
    /// Shown while *imageView* is loading an image.
    private var activityIndicator: UIActivityIndicatorView?
    /// Displays a checkmark is the Amiibo is part of the collection.
    @IBOutlet private weak var purchaseIndicatorView: IndicatorView!
    /// Displays the name of the Amiibo.
    @IBOutlet private weak var nameLabel: UILabel!
    /// Displays the series from which the Amiibo originates.
    @IBOutlet private weak var gameSeriesLabel: UILabel!
    /// Displays the date when the Amiibo was released, or created.
    @IBOutlet private weak var releaseDateLabel: UILabel!
    /// Displays the date when the Amiibo was added to the collection, if there is one.
    @IBOutlet private weak var purchaseDateLabel: UILabel!
    /// Button used to add or remove the Amiibo from the collection.
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
                activityIndicator = imageView.showActivityIndicator()
            }
        } else {
            let defaultImageName = traitCollection.userInterfaceStyle == .light ? "amiibo-logo-light" : "amiibo-logo-dark"
            imageView.image = UIImage(named: defaultImageName)
        }
        
        purchaseDateLabel.isHidden = !isPurchased
        if let purchaseDate = amiibo.purchase?.date {
            let checkmark = traitCollection.userInterfaceStyle == .light ? UIImage(named: "checkmark-light")! : UIImage(named: "checkmark-dark")!
            purchaseIndicatorView.show(checkmark, color: .nintendoGreen, backgroundColor: .clear, animated: false)
            purchaseDateLabel.text = "Purchased: \(Date.displayFormatter.string(from: purchaseDate))"
        }
        
        nameLabel.text = amiibo.name
        gameSeriesLabel.text = amiibo.gameSeries
        releaseDateLabel.text = "Released: \(amiibo.northAmericaRelease)"
        
        actionButton.setTitle(!isPurchased ? "Add to Collection" : "Remove", for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(imageLoaded), name: Notification.Name(rawValue: "imageLoaded"), object: nil)
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
    
    ///
    /// Enables or disabled the action button.
    ///
    /// - parameter enabled: If true, the action button will be enabled.
    ///
    private func setActionButton(enabled: Bool) {
        
        actionButton.isEnabled = enabled
        actionButton.setTitleColor(enabled ? .nintendoGreen : .nintendoFadedGray, for: .normal)
        actionButton.addBorder(width: 3.0, color: enabled ? .nintendoGreen : .nintendoFadedGray)
    }
    
    @IBAction private func actionButtonPressed(_ sender: UIButton) {
        isPurchased ? returnAmiibo() : purchaseAmiibo()
    }
    
    ///
    /// Adds amiibo to the purchase collection.
    ///
    private func purchaseAmiibo() {
        
        do {
            try AmiiboManager.shared.addToCollection(amiibo)
            
            let checkmark = traitCollection.userInterfaceStyle == .light ? UIImage(named: "checkmark-light")! : UIImage(named: "checkmark-dark")!
            setActionButton(enabled: false)
            purchaseIndicatorView.show(checkmark, color: .nintendoGreen, backgroundColor: .clear, animated: true)
            SoundManager.shared.playSound("smb-coin")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
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
            
            setActionButton(enabled: false)
            purchaseIndicatorView.hide(animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                self.dismiss(animated: true, completion: nil)
            })
        } catch {
            showAlert(for: error)
        }
    }
}
