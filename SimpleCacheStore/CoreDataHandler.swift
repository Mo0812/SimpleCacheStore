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
    
    fileprivate var managedObjectContext: NSManagedObjectContext?
    
    init(identifier: String, ressource: String) {
        guard let coreDataUrl = Bundle(identifier: identifier)!.url(forResource: ressource, withExtension: "momd") else {
            fatalError("[CacheManager:init] -> Couldnt find URL")
        }
        guard let mom = NSManagedObjectModel(contentsOf: coreDataUrl) else {
            fatalError("[CacheManager:init] -> Couldnt load MOM")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        self.managedObjectContext?.persistentStoreCoordinator = psc
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.appendingPathComponent(ressource + ".sqlite")
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        } catch {
            fatalError("[CoreDataHandler:init] -> \(error)")
        }
    
        
    }
    
    func getMOC() -> NSManagedObjectContext? {
        return managedObjectContext
    }
    
}
