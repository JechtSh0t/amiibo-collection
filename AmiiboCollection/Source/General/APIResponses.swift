//
//  APIResponses.swift
//  MedlyFlags
//
//  Created by Phil on 11/10/20.
//

import Foundation

///
/// Represents a single country.
///
struct Country: Decodable {
    
    let alpha2Code: String
    let capital: String
    let name: String
    let latlng: [Double]
    
    var flagSource: URL { return URL(string: "https://www.countryflags.io/\(alpha2Code)/flat/64.png")! }
}
