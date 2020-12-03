//
//  AmiiboManager.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/2/20.
//

import Foundation

// MARK: - Delegate -

protocol AmiiboManagerDelegate: class {
    
    func amiboManager(_ manager: AmiiboManager, didUpdateAmibos amibos: [AmiiboManager.Amibo])
    func amiboManager(_ manager: AmiiboManager, didEncounterError error: Error)
}

// MARK: - Class -

///
/// Handles all functions dealing with Amibos.
///
final class AmiiboManager {
    
    // MARK: - Singleton -
    
    static let shared = AmiiboManager()
    private init() {}
    
    private(set) var allAmibos: [Amibo] = []
    var delegate: AmiiboManagerDelegate?
}

// MARK: - API Delegate -

extension AmiiboManager: APIServiceDelegate {
    
    ///
    /// Updates countries with a call to API.
    ///
    func updateAmibos() {
        APIService.shared.getAmibos(delegate: self)
    }
    
    func apiService(_ manager: APIService, didReceiveAmibos amibos: [AmiiboManager.Amibo]) {
        
        allAmibos = amibos
        delegate?.amiboManager(self, didUpdateAmibos: amibos)
    }
    
    func apiService(_ manager: APIService, didEncounterError error: Error, for requestType: APIService.APIRequest) {
        delegate?.amiboManager(self, didEncounterError: error)
    }
}

// MARK: - Nested Types -

extension AmiiboManager {
    
    struct AmiboBank: Decodable {
        let amiibo: [Amibo]
    }
    
    ///
    /// Represents a single Amiibo.
    ///
    struct Amibo: Decodable {
        
        let amiiboSeries: String
        let character: String
        let gameSeries: String
        let head: String
        let image: String
        let name: String
        let release: [String: String?]
        let tail: String
        let type: String
        
        var imageSource: URL { return URL(string: image)! }
    }
}
