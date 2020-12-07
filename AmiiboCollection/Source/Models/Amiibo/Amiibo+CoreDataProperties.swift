//
//  Amiibo+CoreDataProperties.swift
//  AmiiboCollection
//
//  Created by JechtSh0t on 12/5/20.
//

import Foundation
import CoreData

extension Amiibo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Amiibo> {
        return NSFetchRequest<Amiibo>(entityName: "Amiibo")
    }

    @NSManaged public var amiiboSeries: String
    @NSManaged public var character: String
    @NSManaged public var gameSeries: String
    @NSManaged public var head: String
    @NSManaged public var imagePath: String?
    @NSManaged public var name: String
    @NSManaged public var releaseDates: NSDictionary
    @NSManaged public var tail: String
    @NSManaged public var type: String
}
