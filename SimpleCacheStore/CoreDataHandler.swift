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
    
    private var managedObjectContext: NSManagedObjectContext?
    
    init() {
        guard let coreDataUrl = NSBundle(identifier: "MK.SimpleCacheStore")!.URLForResource("SimpleCache", withExtension: "momd") else {
            fatalError("[CacheManager:init] -> Couldnt find URL")
        }
        guard let mom = NSManagedObjectModel(contentsOfURL: coreDataUrl) else {
            fatalError("[CacheManager:init] -> Couldnt load MOM")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.managedObjectContext?.persistentStoreCoordinator = psc
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.URLByAppendingPathComponent("SimpleCache.sqlite")
        do {
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        } catch {
            fatalError("[CoreDataHandler:init] -> \(error)")
        }
    
        
    }
    
    func getMOC() -> NSManagedObjectContext? {
        return managedObjectContext
    }
    
}