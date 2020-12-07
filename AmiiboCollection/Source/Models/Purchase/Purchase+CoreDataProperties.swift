//
//  Purchase+CoreDataProperties.swift
//  AmiiboCollection
//
//  Created by Phil on 12/5/20.
//
//

import Foundation
import CoreData

extension Purchase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Purchase> {
        return NSFetchRequest<Purchase>(entityName: "Purchase")
    }

    @NSManaged public var identifier: String
    @NSManaged public var date: Date
}
