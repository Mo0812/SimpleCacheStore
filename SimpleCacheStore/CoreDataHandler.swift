//
//  CoreDataHandler.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 19.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHandler {
    
    fileprivate var persistentContainer: NSPersistentContainer?
    
    init(container: String) {
        let persistentContainer = NSPersistentContainer(name: container)
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    func getPersistentContainer() -> NSPersistentContainer? {
        return self.persistentContainer
    }
    
}
