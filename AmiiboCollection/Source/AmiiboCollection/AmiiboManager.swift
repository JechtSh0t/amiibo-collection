//
//  AmiiboManager.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/2/20.
//

import Foundation
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
    private(set) var allAmiibos: [Amiibo] = []
    weak var delegate: AmiiboManagerDelegate?
}

// MARK: - Public Interface -

extension AmiiboManager {
    
    ///
    /// Gets available Amiibos. If any local data exists, it is returned and an API call is not made.
    ///
    func getAmiibos() {
        
        do {
            allAmiibos = try getAmiibosFromLocalStorage()
            DispatchQueue.main.async { self.delegate?.amiiboManager(self, didUpdateAmiibos: self.allAmiibos) }
        } catch {
            getAmiibosFromServer()
        }
    }
    
    ///
    /// Updates Amiibos with an API call to the server.
    ///
    func refreshAmiibos() {
        getAmiibosFromServer()
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
            allAmiibos = amiiboBank.amiibo.map { Amiibo($0, context: self.managedObjectContext) }
            try managedObjectContext.save()
            DispatchQueue.main.async { self.delegate?.amiiboManager(self, didUpdateAmiibos: self.allAmiibos) }
            
        } catch {
            DispatchQueue.main.async { self.delegate?.amiiboManager(self, didEncounterError: error) }
        }
    }
    
    ///
    /// Called when *APIService* encounters any error.
    ///
    func apiService(_ manager: APIService, didEncounterError error: Error, request: URLRequest) {
        DispatchQueue.main.async { self.delegate?.amiiboManager(self, didEncounterError: error) }
    }
}

// MARK: - Local Storage -

extension AmiiboManager {
    
    ///
    /// Gets local Amiibos stored with Core Data.
    ///
    private func getAmiibosFromLocalStorage() throws -> [Amiibo] {
        
        debugPrint("Accessing local storage: \(AppDelegate.applicationDocumentsDirectory)")
        let fetchRequest = NSFetchRequest<Amiibo>()
        fetchRequest.entity = Amiibo.entity()
        let sort1 = NSSortDescriptor(key: "head", ascending: true)
        let sort2 = NSSortDescriptor(key: "tail", ascending: true)
        fetchRequest.sortDescriptors = [sort1, sort2]
        
        let amiibos = try managedObjectContext.fetch(fetchRequest)
        guard !amiibos.isEmpty else { throw BSGError(type: .data) }
        
        return amiibos
    }
}

// MARK: - Nested Types -

extension AmiiboManager {
    
    struct CodableAmiiboBank: Decodable {
        let amiibo: [CodableAmiibo]
    }

    struct CodableAmiibo: Decodable {
        
        let amiiboSeries: String
        let character: String
        let gameSeries: String
        let head: String
        let image: String
        let name: String
        let release: [String: String?]
        let tail: String
        let type: String
    }
}
