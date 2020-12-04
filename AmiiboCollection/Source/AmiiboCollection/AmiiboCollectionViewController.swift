//
//  AmiiboCollectionViewController.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/2/20.
//

import UIKit

///
/// Main screen of the application.
///
final class AmiiboCollectionViewController: BaseViewController {

    // MARK: - Properties -
    
    private var selectedIndexPath: IndexPath?
    private var amiibos: [AmiiboManager.Amiibo] { return AmiiboManager.shared.allAmibos }
    
    // MARK: - UI -
    
    @IBOutlet private weak var titleView: UIView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Setup -
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        showProgress()
        AmiiboManager.shared.delegate = self
        AmiiboManager.shared.updateAmibos()
    }
}

// MARK: - Amiibos -

extension AmiiboCollectionViewController: AmiiboManagerDelegate {
    
    func amiboManager(_ manager: AmiiboManager, didUpdateAmibos amibos: [AmiiboManager.Amiibo]) {
        
        hideProgress()
        collectionView.reloadData()
    }
    
    func amiboManager(_ manager: AmiiboManager, didEncounterError error: Error) {
        showAlert(for: error)
    }
}

// MARK: - Collection -

extension AmiiboCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        amiibos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "amiiboCell", for: indexPath) as! AmiiboCell
        cell.configure(for: amiibos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.bounds.width * 0.25
        return CGSize(width: width, height: width * 1.2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "showDetails", sender: nil)
    }
}

// MARK: - Popover -

extension AmiiboCollectionViewController: AmiiboDetailsViewControllerDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let amiiboDetailsVC = segue.destination as? AmiiboDetailsViewController, let selectedIndexPath = selectedIndexPath else { return }
        amiiboDetailsVC.configure(for: amiibos[selectedIndexPath.row], delegate: self)
    }
    
    func amiiboDetailsViewControllerDidExit(_ viewController: AmiiboDetailsViewController) {
        
        if let selectedIndexPath = selectedIndexPath {
            collectionView.deselectItem(at: selectedIndexPath, animated: true)
            self.selectedIndexPath = nil
        }
    }
}
