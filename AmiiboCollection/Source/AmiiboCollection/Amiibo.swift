//
//  Amiibo.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/5/20.
//

import Foundation
import CoreData

public class Amiibo: NSManagedObject {

    // MARK: - Properties -
    
    var imageSource: URL { return URL(string: imagePath)! }
    
    var northAmericaRelease: String {
                
        let decoder = DateFormatter()
        decoder.dateFormat = "yyyy-MM-dd"
        guard let releaseString = releaseDates["na"] as? String, let date = decoder.date(from: releaseString) else { return "N/A" }
        
        let encoder = DateFormatter()
        encoder.dateFormat = "MM/dd/yy"
        return encoder.string(from: date)
    }
    
    // MARK: - Initializers -
    
    convenience init(_ codableAmiibo: AmiiboManager.CodableAmiibo, context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        amiiboSeries = codableAmiibo.amiiboSeries
        character = codableAmiibo.character
        gameSeries = codableAmiibo.gameSeries
        head = codableAmiibo.head
        imagePath = codableAmiibo.image
        name = codableAmiibo.name
        releaseDates = codableAmiibo.release as NSDictionary
        tail = codableAmiibo.tail
        type = codableAmiibo.type
    }
}
