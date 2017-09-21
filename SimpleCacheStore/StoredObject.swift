//
//  StoredObject.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 21.09.17.
//  Copyright © 2017 Moritz Kanzler. All rights reserved.
//

import Foundation
import CoreData

class StoredObject: NSManagedObject {
    @NSManaged var identifier: String?
    @NSManaged var label: String?
    @NSManaged var created: Date?
    @NSManaged var lastUpdate: Date?
    @NSManaged var requested: Int64
    @NSManaged var object: Data?
}
