//
//  APIService.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/2/20.
//

import Foundation

// MARK: - Delegate -

protocol APIServiceDelegate {
    
    func apiService(_ manager: APIService, didReceiveAmibos countries: [AmiiboManager.Amibo])
    func apiService(_ manager: APIService, didEncounterError error: Error, for requestType: APIService.APIRequest)
}

// MARK: - Class -

///
/// Handles JSON API calls.
///
final class APIService {
    
    enum APIRequest {
        case amibos
    }
    
    // MARK: - Singleton -
    
    static let shared = APIService()
    private init() {}
    
    // MARK: - Private Properties -

    /// Session used for all API calls
    private lazy var session = URLSession.shared
}

// MARK: - Amibos -

extension APIService {
    
    ///
    /// Returns all available Amibos.
    ///
    /// - parameter delegate: The object that will handle responses.
    ///
    func getAmibos(delegate: APIServiceDelegate) {
        
        guard let url = URL(string: "https://www.amiiboapi.com/api/amiibo") else { return }
        performRequest(.amibos, url: url, delegate: delegate)
    }
}

// MARK: - General Request Handling -

extension APIService {
    
    ///
    /// Generic method for making an API call to any endpoint.
    ///
    /// - parameter apiRequest: The type of API call to be made.
    /// - parameter url: The endpoint of the call.
    /// - parameter delegate: The object that will handle responses.
    ///
    private func performRequest(_ apiRequest: APIRequest, url: URL, delegate: APIServiceDelegate) {
        
        debugPrint("API call: \(url)")
        let request = NSURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            do {
                if let error = error { throw error }
                guard let data = data else { throw BSGError(type: .data) }
                
                self.decodeData(data, for: apiRequest, delegate: delegate)
                
            } catch {
                DispatchQueue.main.async { delegate.apiService(self, didEncounterError: error, for: apiRequest) }
            }
        })

        dataTask.resume()
    }
    
    ///
    /// Method for handling the results of an API call.
    ///
    /// - parameter data: The data returned from API.
    /// - parameter request: The type of API call that was made. Determines how to parse data.
    /// - parameter delegate: The object that will handle the results of API call.
    ///
    private func decodeData(_ data: Data, for request: APIRequest, delegate: APIServiceDelegate) {
        
        do {
            
            switch request {
                
            case .amibos:
                
                guard let amiboBank = try? JSONDecoder().decode(AmiiboManager.AmiboBank.self, from: data) else { throw BSGError(type: .data) }
                DispatchQueue.main.async { delegate.apiService(self, didReceiveAmibos: amiboBank.amiibo) }
            }
            
        } catch {
            
            DispatchQueue.main.async { delegate.apiService(self, didEncounterError: error, for: request) }
        }
    }
}
