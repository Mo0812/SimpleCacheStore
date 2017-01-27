//
//  Snapshot.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 23.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation
import CoreData


class Snapshot: NSManagedObject {
    
    @NSManaged var created: Date?
    @NSManaged var data: Data?
    
}
