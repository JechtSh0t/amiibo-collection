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
    
    /// The current size of collection cells. This changes with the orientation of the UI.
    private var cellSize: CGSize!
    /// The last cell that was selected, if a popover is active.
    private var selectedIndexPath: IndexPath?
    /// Shortcut for accessing Amiibos.
    private var amiibos: [Amiibo] { return AmiiboManager.shared.filteredAmiibos }
    /// The current filter type for Amiibos, based on the position of the segmented control.
    private var selectedFilterType: AmiiboManager.FilterType {
        guard let filterType = AmiiboManager.FilterType(rawValue: filterSegmentedControl.selectedSegmentIndex) else { return .all}
        return filterType
    }
    
    // MARK: - UI -
    
    /// Displays the title of the application.
    @IBOutlet private weak var titleImageView: UIImageView!
    /// Used to create a new Amiibo.
    @IBOutlet private weak var createButton: UIButton!
    /// Used to switch the Amiibo filter.
    @IBOutlet private weak var filterSegmentedControl: UISegmentedControl!
    /// Collection of Amiibo cells.
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
    
    override func style() {
        
        super.style()
        
        createButton.tintColor = .nintendoGreen
        
        if #available(iOS 13.0, *) {
            filterSegmentedControl.selectedSegmentTintColor = .nintendoGreen
            filterSegmentedControl.backgroundColor = .systemBackground
        } else {
            filterSegmentedControl.tintColor = .nintendoGreen
        }
    }
    
    override func lightStyle() {
        
        super.lightStyle()
        titleImageView.image = UIImage(named: "amiibo-light")
        
        let font = UIFont(name: "bauhaus", size: traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular ? 22.0 : 16.0)!
        filterSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
    }
    
    override func darkStyle() {
        
        super.darkStyle()
        titleImageView.image = UIImage(named: "amiibo-dark")
        
        let font = UIFont(name: "bauhaus", size: traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular ? 22.0 : 16.0)!
        filterSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
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

// MARK: - Filter -

extension AmiiboCollectionViewController {
    
    @IBAction private func filterChanged(_ sender: UISegmentedControl) {
        
        AmiiboManager.shared.filterAmiibos(by: selectedFilterType)
        collectionView.reloadData()
    }
}

// MARK: - Collection -

extension AmiiboCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        cellSize = calculateCellSize(viewSize: size)
    }
    
    ///
    /// Determines the proper size of cells based on UI orientation.
    ///
    /// - parameter size: The current frame size of the view.
    ///
    private func calculateCellSize(viewSize: CGSize) -> CGSize {
        
        let cellsPerRow = viewSize.width > viewSize.height ? 5 : 3
        let cellWidth = (viewSize.width * 0.80) / CGFloat(cellsPerRow)
        return CGSize(width: cellWidth, height: cellWidth * 1.2)
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
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

// MARK: - Popovers -

extension AmiiboCollectionViewController: CreateAmiiboViewControllerDelegate, AmiiboDetailsViewControllerDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier {
        
        case "showCreate":
            guard let createAmiiboVC = segue.destination as? CreateAmiiboViewController else { return }
            createAmiiboVC.configure(delegate: self)
            
        case "showDetails":
            guard let amiiboDetailsVC = segue.destination as? AmiiboDetailsViewController, let selectedIndexPath = selectedIndexPath else { return }
            amiiboDetailsVC.configure(for: amiibos[selectedIndexPath.row], delegate: self)
            
        default: break
        }
    }
    
    func createAmiiboViewController(_ viewController: CreateAmiiboViewController, didCreateAmiibo amiibo: Amiibo) {
        
        AmiiboManager.shared.filterAmiibos(by: selectedFilterType)
        collectionView.reloadData()
    }
    
    func amiiboDetailsViewControllerWillDismiss(_ viewController: AmiiboDetailsViewController) {
        
        self.selectedIndexPath = nil
        
        AmiiboManager.shared.filterAmiibos(by: selectedFilterType)
        collectionView.reloadData()
    }
}
