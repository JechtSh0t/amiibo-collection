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
    
    private var cellSize: CGSize!
    private var selectedIndexPath: IndexPath?
    private var amiibos: [Amiibo] { return AmiiboManager.shared.allAmiibos }
    
    // MARK: - UI -
    
    @IBOutlet private weak var titleImageView: UIImageView!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    /// Allows pull to refresh on the table.
    private lazy var refreshControl: UIRefreshControl = {
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = traitCollection.userInterfaceStyle == .light ? .black : .white
        refreshControl.addTarget(self, action: #selector(refreshActivated(_:)), for: .valueChanged)
        return refreshControl
    }()
    
    // MARK: - Setup -
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        showProgress()
        collectionView.refreshControl = refreshControl
        AmiiboManager.shared.delegate = self
        AmiiboManager.shared.getAmiibos()
        
        cellSize = calculateCellSize(viewSize: view.bounds.size)
    }
    
    override func lightStyle() {
        
        super.lightStyle()
        titleImageView.image = UIImage(named: "amiibo-light")
    }
    
    override func darkStyle() {
        
        super.darkStyle()
        titleImageView.image = UIImage(named: "amiibo-dark")
    }
    
    private func calculateCellSize(viewSize: CGSize) -> CGSize {
        
        let cellsPerRow = viewSize.width > viewSize.height ? 5 : 3
        let cellWidth = (viewSize.width * 0.75) / CGFloat(cellsPerRow)
        return CGSize(width: cellWidth, height: cellWidth * 1.2)
    }
}

// MARK: - Amiibos -

extension AmiiboCollectionViewController: AmiiboManagerDelegate {
    
    func amiiboManager(_ manager: AmiiboManager, didUpdateAmiibos amiibos: [Amiibo]) {
        
        hideProgress()
        refreshControl.endRefreshing()
        collectionView.reloadData()
    }
    
    func amiiboManager(_ manager: AmiiboManager, didEncounterError error: Error) {
        
        refreshControl.endRefreshing()
        showAlert(for: error)
    }
}

// MARK: - Collection -

extension AmiiboCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        cellSize = calculateCellSize(viewSize: size)
        collectionView.reloadData()
    }
    
    ///
    /// Called when refresh is activated by a pull.
    ///
    @IBAction @objc func refreshActivated(_ sender: UIRefreshControl) {
        AmiiboManager.shared.refreshAmiibos()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        amiibos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "amiiboCell", for: indexPath) as! AmiiboCell
        cell.configure(for: amiibos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
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
    
    func amiiboDetailsViewControllerWillDismiss(_ viewController: AmiiboDetailsViewController) {
        
        if let selectedIndexPath = selectedIndexPath {
            collectionView.reloadItems(at: [selectedIndexPath])
            self.selectedIndexPath = nil
        }
    }
}
