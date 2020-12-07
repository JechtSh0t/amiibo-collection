//
//  AmiiboManager.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/2/20.
//

import UIKit
import CoreData

// MARK: - Delegate -

protocol AmiiboManagerDelegate: class {
    
    /// Called when *AmiiboManager* successfully updates amiibos.
    func amiiboManager(_ manager: AmiiboManager, didUpdateAmiibos amiibos: [Amiibo])
    /// Called when *AmiiboManager* encounters any error.
    func amiiboManager(_ manager: AmiiboManager, didEncounterError error: Error)
}

// MARK: - Class -

///
/// Handles all functions dealing with Amibos.
///
final class AmiiboManager {
    
    // MARK: - Singleton -
    
    static let shared = AmiiboManager()
    private init() {}
    
    // MARK: - Properties -
    
    var managedObjectContext: NSManagedObjectContext!
    private(set) var allAmiibos: [Amiibo] = [] { didSet { filterAmiibos(by: currentFilter) } }
    private var currentFilter: FilterType = .all
    private(set) var filteredAmiibos: [Amiibo] = []
    /// The number of Amiibos that have been created by the user.
    private var creationCount: Int {
        get { UserDefaults.standard.value(forKey: "next-user-ID") as? Int ?? 0 }
        set { UserDefaults.standard.setValue(newValue, forKey: "next-user-ID") }
    }
    weak var delegate: AmiiboManagerDelegate?
}

// MARK: - Fetching Amiibos -

extension AmiiboManager {
    
    ///
    /// Gets available Amiibos. If any local data exists, it is returned and an API call is not made.
    ///
    func getAmiibos() {
        
        do {
            allAmiibos = try getAmiibosFromLocalStorage()
            delegate?.amiiboManager(self, didUpdateAmiibos: self.allAmiibos)
        } catch {
            debugPrint("Failed to load from local storage")
            getAmiibosFromServer()
        }
    }
    
    ///
    /// Updates Amiibos with an API call to the server.
    ///
    func refreshAmiibos() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Amiibo")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedObjectContext.execute(batchDeleteRequest)
            debugPrint("Local storage cleared")
            getAmiibosFromServer()
        } catch {
            delegate?.amiiboManager(self, didEncounterError: error)
        }
    }
}

// MARK: - API -

extension AmiiboManager: APIServiceDelegate {
    
    ///
    /// Updates amiibos with a call to API.
    ///
    private func getAmiibosFromServer() {
        
        debugPrint("Accessing server")
        guard let url = URL(string: "https://www.amiiboapi.com/api/amiibo") else { return }
        APIService.shared.performRequest(url: url, delegate: self)
    }
    
    ///
    /// Called when *APIService* successfully obtains data.
    ///
    func apiService(_ manager: APIService, didReceiveData data: Data, request: URLRequest) {
        
        do {
            
            let amiiboBank = try JSONDecoder().decode(CodableAmiiboBank.self, from: data)
            debugPrint("Received \(amiiboBank.amiibo.count) Amiibos from server")
            allAmiibos = amiiboBank.amiibo.map {
                let amiibo = Amiibo($0, context: self.managedObjectContext)
                amiibo.purchase = try? getPurchase(of: amiibo)
                return amiibo
            }
            
            try managedObjectContext.save()
            delegate?.amiiboManager(self, didUpdateAmiibos: self.allAmiibos)
            
        } catch {
            delegate?.amiiboManager(self, didEncounterError: error)
        }
    }
    
    ///
    /// Called when *APIService* encounters any error.
    ///
    func apiService(_ manager: APIService, didEncounterError error: Error, request: URLRequest) {
        delegate?.amiiboManager(self, didEncounterError: error)
    }
}

// MARK: - Local Storage -

extension AmiiboManager {
    
    ///
    /// Gets local Amiibos stored with Core Data. Amiibos are fetched in order sorted by identifier.
    ///
    private func getAmiibosFromLocalStorage() throws -> [Amiibo] {
        
        debugPrint("Accessing local storage: \(AppDelegate.applicationDocumentsDirectory)")
        let fetchRequest = NSFetchRequest<Amiibo>()
        fetchRequest.entity = Amiibo.entity()
        let sort1 = NSSortDescriptor(key: "head", ascending: true)
        let sort2 = NSSortDescriptor(key: "tail", ascending: true)
        fetchRequest.sortDescriptors = [sort1, sort2]
        
        let amiibos = try managedObjectContext.fetch(fetchRequest)
        amiibos.forEach { $0.purchase = try? getPurchase(of: $0) }
        guard !amiibos.isEmpty else { throw BSGError(type: .data) }
        
        return amiibos
    }
}

// MARK: - Filters -

extension AmiiboManager {
    
    enum FilterType: Int {
        case all
        case collection
    }
    
    func filterAmiibos(by filterType: FilterType) {
        
        currentFilter = filterType
        
        switch filterType {
        case .all: filteredAmiibos = allAmiibos
        case .collection: filteredAmiibos = allAmiibos.filter { $0.purchase != nil }
        }
    }
}

// MARK: - Purchases -

extension AmiiboManager {
    
    func getPurchase(of amiibo: Amiibo) throws -> Purchase? {
        
        let fetchRequest = NSFetchRequest<Purchase>()
        fetchRequest.entity = Purchase.entity()
        let predicate = NSPredicate(format: "identifier == %@", amiibo.identifier)
        fetchRequest.predicate = predicate
        
        let purchases = try managedObjectContext.fetch(fetchRequest)
        return purchases.isEmpty ? nil : purchases[0]
    }
    
    ///
    /// Adds an amiibo to the purchased collection.
    ///
    /// - parameter amiibo: The Amiibo to purchase.
    ///
    func addToCollection(_ amiibo: Amiibo) throws {
        
        let purchase = Purchase(context: managedObjectContext)
        purchase.identifier = amiibo.identifier
        purchase.date = Date()
        try managedObjectContext.save()
        amiibo.purchase = purchase
    }
    
    func removeFromCollection(_ amiibo: Amiibo) throws {
        
        guard let purchase = try? getPurchase(of: amiibo) else { return }
        managedObjectContext.delete(purchase)
        try managedObjectContext.save()
        amiibo.purchase = nil
    }
}

// MARK: - Creation -

extension AmiiboManager {
    
    func createAmiibo(withName name: String, image: UIImage?) throws -> Amiibo {
        
        let tailValue = String(format: "%08d", creationCount)
        let amiibo = Amiibo(name: name, tailValue: tailValue, containsImage: image != nil, context: managedObjectContext)
        try managedObjectContext.save()
        creationCount += 1
        allAmiibos.append(amiibo)
        
        if let image = image, let imagePath = amiibo.imagePath {
            ImageManager.shared.saveImageToCache(image, name: imagePath)
        }
        
        return amiibo
    }
}

// MARK: - Nested Types -

extension AmiiboManager {
    
    struct CodableAmiiboBank: Decodable {
        let amiibo: [CodableAmiibo]
    }

    struct CodableAmiibo: Decodable {
        
        let head: String
        let tail: String
        let name: String
        let character: String
        let amiiboSeries: String
        let gameSeries: String
        let image: String
        let release: [String: String?]
        let type: String
    }
}
