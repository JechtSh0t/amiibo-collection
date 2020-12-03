//
//  BaseCollectionCell.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/2/20.
//
import UIKit

///
/// Contains base functionality for all Table Cells.
///
class BaseCollectionCell: UICollectionViewCell {
    
    // MARK: - Setup -
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        style()
    }
    
    ///
    /// Style adjustments.
    ///
    func style() {}
}

// MARK: - Interface Style Change -

extension BaseCollectionCell {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        style()
    }
}
