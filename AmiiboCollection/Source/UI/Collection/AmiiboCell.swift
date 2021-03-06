//
//  AmiiboCell.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/2/20.
//

import UIKit

///
/// Cell displaying a single Amiibo.
///
final class AmiiboCell: BaseCollectionCell {
    
    // MARK: - Properties -
    
    /// The single Amiibo that the cell is configured to display.
    private var amiibo: Amiibo!
    
    // MARK: - UI -
    
    /// Displays an image of the Amiibo.
    @IBOutlet private weak var imageView: UIImageView!
    /// Shown while *imageView* is loading an image.
    private var activityIndicator: UIActivityIndicatorView?
    /// Displays a checkmark for a purchsed Amiibo.
    @IBOutlet private weak var purchaseIndicatorView: IndicatorView!
    /// Displays the name of the Amiibo.
    @IBOutlet private weak var nameLabel: UILabel!
    
    // MARK: - Setup -
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(imageLoaded), name: Notification.Name(rawValue: "imageLoaded"), object: nil)
    }
    
    override func style() {
        
        super.style()
        
        roundCorners()
        
        let selectionView = UIView()
        selectionView.backgroundColor = .nintendoFadedGray
        selectedBackgroundView = selectionView
    }
    
    func configure(for amiibo: Amiibo) {
        
        contentView.alpha = amiibo.purchase != nil ? 1.0 : 0.4
        
        self.amiibo = amiibo
        nameLabel.text = amiibo.name
        
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
        
        if amiibo.purchase != nil {
            let checkmark = traitCollection.userInterfaceStyle == .light ? UIImage(named: "checkmark-light")! : UIImage(named: "checkmark-dark")!
            purchaseIndicatorView.show(checkmark, color: .nintendoGreen, backgroundColor: .clear, animated: false)
        } else {
            purchaseIndicatorView.hide(animated: false)
        }
    }
}

// MARK: - Image Loading -

extension AmiiboCell {
    
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
