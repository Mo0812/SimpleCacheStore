//
//  SCCoreDataWalker.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 19.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation
import CoreData

class SCCoreDataWalker {
    
    private var managedObjectContext: NSManagedObjectContext?
    
    init() {
        let coreDataHandler = CoreDataHandler()
        self.managedObjectContext = coreDataHandler.getMOC()
        
    }
    
    private func fetchExpiredObjects(answer: (Bool, [CacheObject]?) -> ()) {
        let fetchRequest = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entityForName("CacheObject", inManagedObjectContext: self.managedObjectContext!)
        
        fetchRequest.entity = entityDescription
        fetchRequest.predicate = NSPredicate(format: "created <= %@", SCGlobalOptions.Options.expiringDate)
        
        
        do {
            let result = try self.managedObjectContext?.executeFetchRequest(fetchRequest) as! [CacheObject]
            answer(true, result)
        } catch {
            answer(false, nil)
            fatalError("[CacheManager:getObject] -> Fehler beim Lesen von Daten")
        }
    }
    
    private func deleteExpiringObjects() -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "CacheObject")
        fetchRequest.predicate = NSPredicate(format: "identifier <= %@", SCGlobalOptions.Options.expiringDate)
        
        do {
            let result = try self.managedObjectContext?.executeFetchRequest(fetchRequest) as! [CacheObject]
            
            for cacheObject in result {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
                if let date = cacheObject.created {
                    print("[SCCoreDataWalker] -> " + cacheObject.identifier! + " " + formatter.stringFromDate(date))
                }
                self.managedObjectContext?.deleteObject(cacheObject)
            }
        } catch {
            return false
        }
        
        do {
            try self.managedObjectContext?.save()
            return true
        } catch {
             return false
        }
    }
    
    func cleanCache() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            self.deleteExpiringObjects()
        })
    }
    
}
