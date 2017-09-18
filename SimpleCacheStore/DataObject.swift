//
//  DataObject.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 19.09.17.
//  Copyright © 2017 Moritz Kanzler. All rights reserved.
//

import Foundation
import CoreData


class DataObject: NSManagedObject {
    
    @NSManaged var identifier: String?
    @NSManaged var data: Data?
    
}
