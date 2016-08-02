//
//  SCCacheWalker.swift
//  SimpleCacheStore
//
//  Created by Moritz Kanzler on 23.07.16.
//  Copyright © 2016 Moritz Kanzler. All rights reserved.
//

import Foundation
import CoreData

class SCCacheWalker {
    
    let cm: SCCacheManager
    let  moc: NSManagedObjectContext?
    
    init() {
        cm = SCCacheManager.sharedInstance
        let cdh = CoreDataHandler(identifier: "MK.SimpleCacheStore", ressource: "SCSnapshot")
        moc = cdh.getMOC()
    }
    
    func saveSnapshot() {
        
        let cacheDictionary = cm.getCacheDictionary()
        
        let entity = NSEntityDescription.insertNewObjectForEntityForName("Snapshot", inManagedObjectContext: self.moc!) as! Snapshot
        entity.setValue(NSDate(), forKey: "created")
        
        let cacheData =  NSKeyedArchiver.archivedDataWithRootObject(cacheDictionary)
        entity.setValue(cacheData, forKey: "data")
        
        
        do {
            try self.moc?.save()
        } catch {
            
        }
        
        print("SNAPSHOT ERSTELLT")
        
    }
    
    func restoreSnapshot() {
        let fetchRequest = NSFetchRequest()
        
        let entityDescription = NSEntityDescription.entityForName("Snapshot", inManagedObjectContext: self.moc!)
        
        fetchRequest.entity = entityDescription
        //fetchRequest.predicate = NSPredicate(format: "created <= %@", NSDate())
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        
        do {
            let result = try self.moc?.executeFetchRequest(fetchRequest) as! [Snapshot]
            if !result.isEmpty {
                
                if let latestSnapShot = result[0].data {
                    if let snapshot = NSKeyedUnarchiver.unarchiveObjectWithData(latestSnapShot) as? Dictionary<String, NSObject> {
                        cm.setCache(snapshot)
                    }
                }
            }
        } catch {
            fatalError("[CacheManager:getObject] -> Fehler beim Lesen von Daten")
        }
        
        print("SNAPSHOT RESTORED")
    }
    
    func establishCacheFromPersistentObjects(answer: (Bool) -> ()) {
        let cdm = SCCoreDataManager()
        dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), {
            cdm.getObjectDump({
                objectDict in
                if let persistentObjects = objectDict {
                    self.cm.setCache(persistentObjects)
                    answer(true)
                }
            })
        })
    }
    
}