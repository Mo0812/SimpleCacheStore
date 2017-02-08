//
//  CacheObject.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 15.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation
import CoreData


class CacheObject: NSManagedObject {

    @NSManaged var identifier: String?
    @NSManaged var label: String?
    @NSManaged var created: Date?
    @NSManaged var lastUpdate: Date?
    @NSManaged var requested: Int64
    @NSManaged var object: Data?

}
