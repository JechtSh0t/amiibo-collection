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

    /// Unique identifier for the Amiibo.
    var identifier: String { return head + tail }
    /// Download URL for the image.
    var imageSource: URL? {
        guard let imagePath = imagePath else { return nil}
        return URL(string: imagePath)
    }
    /// Contains details about the purchase of the Amiibo.
    var purchase: Purchase?
    
    /// The date when the Amiibo was released in North America, in a user-friendly format.
    var northAmericaRelease: String {
                
        guard let releaseString = releaseDates["na"] as? String, let date = Date.storageFormatter.date(from: releaseString) else { return "N/A" }
        return Date.displayFormatter.string(from: date)
    }
    
    // MARK: - Initializers -
    
    convenience init(name: String, tailValue: String, containsImage: Bool, context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        head = "FFFFFFFF"
        tail = tailValue
        self.name = name
        character = name
        amiiboSeries = "User Created"
        gameSeries = "User Created"
        self.imagePath = containsImage ? "icon_\(head)-\(tail)" : nil
        let encodedDate = Date.storageFormatter.string(from: Date())
        releaseDates = ["na": encodedDate]
        type = "Unknown"
    }
    
    convenience init(_ codableAmiibo: AmiiboManager.CodableAmiibo, context: NSManagedObjectContext) {
        
        self.init(context: context)
        
        head = codableAmiibo.head
        tail = codableAmiibo.tail
        name = codableAmiibo.name
        character = codableAmiibo.character
        amiiboSeries = codableAmiibo.amiiboSeries
        gameSeries = codableAmiibo.gameSeries
        imagePath = codableAmiibo.image
        releaseDates = codableAmiibo.release as NSDictionary
        type = codableAmiibo.type
    }
}
