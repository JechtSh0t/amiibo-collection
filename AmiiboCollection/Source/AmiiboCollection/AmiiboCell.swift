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
    
    private var amiibo: AmiiboManager.Amiibo!
    
    // MARK: - UI -
    
    @IBOutlet private weak var imageView: UIImageView!
    private var activityIndicator: UIActivityIndicatorView?
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
    
    func configure(for amiibo: AmiiboManager.Amiibo) {
        
        self.amiibo = amiibo
        nameLabel.text = amiibo.name
        
        if let cachedImage = ImageManager.shared.loadImage(amiibo.imageSource) {
            imageView.image = cachedImage
        } else {
            activityIndicator = imageView.showActivityIndicator(style: .medium)
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
