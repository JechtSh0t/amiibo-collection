//
//  AmiiboManager.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/2/20.
//

import Foundation

// MARK: - Delegate -

protocol AmiiboManagerDelegate: class {
    
    func amiboManager(_ manager: AmiiboManager, didUpdateAmibos amibos: [AmiiboManager.Amiibo])
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
    
    private(set) var allAmibos: [Amiibo] = []
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
    
    func apiService(_ manager: APIService, didReceiveAmibos amibos: [AmiiboManager.Amiibo]) {
        
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
        let amiibo: [Amiibo]
    }
    
    ///
    /// Represents a single Amiibo.
    ///
    struct Amiibo: Decodable {
        
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
        
        var northAmericaRelease: String {
                    
            let decoder = DateFormatter()
            decoder.dateFormat = "yyyy-MM-dd"
            guard let releaseString = release["na"] as? String, let date = decoder.date(from: releaseString) else { return "N/A" }
            
            let encoder = DateFormatter()
            encoder.dateFormat = "MM/dd/yy"
            return encoder.string(from: date)
        }
    }
}
