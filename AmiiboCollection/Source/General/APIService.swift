//
//  APIService.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/2/20.
//

import Foundation

// MARK: - Delegate -

protocol APIServiceDelegate {
    
    func apiService(_ manager: APIService, didReceiveData data: Data, request: URLRequest)
    func apiService(_ manager: APIService, didEncounterError error: Error, request: URLRequest)
}

// MARK: - Class -

///
/// Handles API calls.
///
final class APIService {
    
    // MARK: - Singleton -
    
    static let shared = APIService()
    private init() {}
    
    // MARK: - Private Properties -

    /// Session used for all API calls
    private lazy var session = URLSession.shared
}

// MARK: - General Request Handling -

extension APIService {
    
    ///
    /// Generic method for making an API call to any endpoint.
    ///
    /// - parameter url: The endpoint of the call.
    /// - parameter delegate: The object that will handle responses.
    ///
    func performRequest(url: URL, delegate: APIServiceDelegate) {
        
        debugPrint("API call: \(url)")
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        
        let dataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            
            do {
                if let error = error { throw error }
                guard let data = data else { throw BSGError(type: .data) }
                delegate.apiService(self, didReceiveData: data, request: request)
                
            } catch {
                delegate.apiService(self, didEncounterError: error, request: request)
            }
        })

        dataTask.resume()
    }
}
